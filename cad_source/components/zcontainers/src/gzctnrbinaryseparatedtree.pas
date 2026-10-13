{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit gzctnrBinarySeparatedTree;

interface

uses
  gzctnrVectorTypes;

type
  TStageMode=(TSMStart,TSMAccumulation,TSMCalc,TSMEnd);

  TNodeDir=(TND_Plus,TND_Minus,TND_Root);

  TElemPosition=(TEP_Plus,TEP_Minus,TEP_nul);

  GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
    TEntityArrayIterateResult,TEntityArray>=record
  type
    PGZBInarySeparatedGeometry=^GZBInarySeparatedGeometry<
      TBoundingBox,    //ограничивающий объем
      TSeparator,      //разделитель
      TNodeData,       //дополнительные данные в ноде
      TEntsManipulator,//то что невозможно закодировать в генерике
      TEntity,         //примитив
      TEntityArrayIterateResult,
      TEntityArray>;   //массив примитивов
    PTEntity=^TEntity;

    TTestNode=record
      plane:TSeparator;
      nul,plus,minus:TEntityArray;
      constructor initnul(InNodeCount:integer);
      procedure done;
    end;

    var
      //NodeData должен идти первым. GDBObjEntity.GetInfrustumFromTree расчитывает на это
      NodeData:TNodeData;
      pplusnode,pminusnode:PGZBInarySeparatedGeometry;
      nul:TEntityArray;
      Separator:TSeparator;
      BoundingBox:TBoundingBox;
      NodeDir:TNodeDir;
      Root:PGZBInarySeparatedGeometry;
      LockCounter:integer;

    procedure done;
    procedure ClearSub;
    procedure Shrink;
    procedure initnul;
    procedure AddObjToNul(var Entity:TEntity);
    procedure updateenttreeadress;
    procedure CorrectNodeBoundingBox(var AEntity:TEntity;ASetToThis:boolean=False);inline;
    procedure AddObjectToNodeTree(var Entity:TEntity);
    procedure SetSize(ns:integer);
    procedure Lock;
    procedure UnLock;
    procedure Separate;
    function GetNodeDepth:integer;
    procedure MoveSub(var node:GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>);
    function GetOptimalTestNode(var TNArray:array of TTestNode):integer;
    procedure StoreOptimalTestNode(var TestNode:TTestNode);

    function nuliterate(var ir:itrec):Pointer;
    function nulbeginiterate(out ir:itrec):Pointer;
    function nulDeleteElement(index:integer):Pointer;
  end;

implementation

constructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.TTestNode.initnul;
begin
  nul.init(InNodeCount);
  plus.init(InNodeCount);
  minus.init(InNodeCount);
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.TTestNode.done;
begin
  nul.Clear;
  nul.Done;
  plus.Clear;
  plus.Done;
  minus.Clear;
  minus.Done;
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.Lock;
begin
  Inc(LockCounter);
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.UnLock;
begin
  Dec(LockCounter);
  if LockCounter=0 then
    separate;
end;

function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.GetNodeDepth:integer;
begin
  if Root=nil then
    Result:=0
  else
    Result:=1+Root^.GetNodeDepth;
end;

function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.GetOptimalTestNode(
  var TNArray:array of TTestNode):integer;
var
  entcount,dentcount,i:integer;
begin
  entcount:=TNArray[0].nul.Count;
  dentcount:=abs(TNArray[0].plus.Count-TNArray[0].minus.Count);
  Result:=0;
  for i:=1 to high(TNArray) do begin
    if TNArray[i].nul.Count<entcount then begin
      entcount:=TNArray[i].nul.Count;
      dentcount:=abs(TNArray[i].plus.Count-TNArray[i].minus.Count);
      Result:=i;
    end else if TNArray[i].nul.Count=entcount then begin
      if abs(TNArray[i].plus.Count-TNArray[i].minus.Count)<dentcount then begin
        entcount:=TNArray[i].nul.Count;
        dentcount:=abs(TNArray[i].plus.Count-TNArray[i].minus.Count);
        Result:=i;
      end;
    end;
  end;
end;

function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.nuliterate(
  var ir:itrec):Pointer;
begin
  Result:=nul.iterate(ir);
  Result:=TEntsManipulator.IterateResult2PEntity(Result);
end;

function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.nulbeginiterate(out ir:itrec):Pointer;
begin
  Result:=nul.beginiterate(ir);
  Result:=TEntsManipulator.IterateResult2PEntity(Result);
end;

function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.nulDeleteElement(index:integer):Pointer;
begin
  Result:=nul.DeleteElement(index);
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.StoreOptimalTestNode(var TestNode:TTestNode);
var
  pobj:PTEntity;
  ir:itrec;
begin
  nul.Clear;
  nul.setsize(TestNode.nul.Count);
  TestNode.nul.copyto(nul);
  Separator:=TestNode.plane;
  if TestNode.plus.Count>0 then begin
    if pplusnode=nil then begin
      Getmem(pointer(pplusnode),sizeof(GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,
        TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>));
      pplusnode.initnul;
    end;
    pplusnode.lock;
    pplusnode.root:=@self;
    pplusnode.setsize(TestNode.plus.Count);
    pobj:=TestNode.plus.beginiterate(ir);
    if pobj<>nil then
      repeat
        pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
        pplusnode.AddObjectToNodeTree(pobj^);
        pobj:=TestNode.plus.iterate(ir);
      until pobj=nil;
    pplusnode.unlock;
  end;
  if TestNode.minus.Count>0 then begin
    if pminusnode=nil then begin
      Getmem(pointer(pminusnode),sizeof(GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,
        TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>));
      pminusnode.initnul;
    end;
    pminusnode.lock;
    pminusnode.root:=@self;
    pminusnode.setsize(TestNode.minus.Count);
    pobj:=TestNode.minus.beginiterate(ir);
    if pobj<>nil then
      repeat
        pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
        pminusnode.AddObjectToNodeTree(pobj^);
        pobj:=TestNode.minus.iterate(ir);
      until pobj=nil;
    pminusnode.unlock;
  end;
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.Separate;
var
  i:integer;
  PFirstStageData:pointer;
  pobj:PTEntity;
  ir:itrec;
  ep:TElemPosition;

  entcount:integer=MaxInt;
  dentcount:integer=MaxInt;
  plus_count,minus_count,nul_count:integer;
  plus_count_optimal,minus_count_optimal,nul_count_optimal:integer;
  TestNode:TTestNode;
  nul_optimal,temp_entarr:TEntityArray;
  plane_optimal:TSeparator;

  testSeparatorCount:integer;
  isVeryOptimal:boolean;
  TenPercentOfTotalCount:integer;

  function IsOptimalTestNode:boolean;
  var
    d:integer;
  begin
    d:=abs(plus_count-minus_count);
    if (nul_count=0)and(d<TenPercentOfTotalCount) then begin
      entcount:=nul_count;
      dentcount:=d;
      Result:=True;
      isVeryOptimal:=True;
    end else if nul_count<entcount then begin
      entcount:=nul_count;
      dentcount:=d;
      Result:=True;
    end else if nul_count=entcount then begin
      if d<dentcount then begin
        entcount:=nul_count;
        dentcount:=d;
        Result:=True;
      end;
    end else
      Result:=False;

  end;

begin
  if TEntsManipulator.isUnneedSeparate(nul.Count,GetNodeDepth) then begin
    updateenttreeadress;
    NodeData.AfterSeparateNode(nul);
    exit;
  end;
  MoveSub(self);
  TenPercentOfTotalCount:=nul.Count div 10;
  PFirstStageData:=nil;
  TEntsManipulator.FirstStageCalcSeparatirs(BoundingBox,TEntity(nil^),PFirstStageData,TSMStart);
  if PFirstStageData<>nil then begin
    pobj:=nul.beginiterate(ir);
    if pobj<>nil then
      repeat
        pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
        TEntsManipulator.FirstStageCalcSeparatirs(BoundingBox,pobj^,PFirstStageData,TSMAccumulation);

        pobj:=nul.iterate(ir);
      until pobj=nil;
  end;
  TEntsManipulator.FirstStageCalcSeparatirs(BoundingBox,TEntity(nil^),PFirstStageData,TSMCalc);

  // подсчёт +/-/nul
  plus_count_optimal:=0;
  minus_count_optimal:=0;
  nul_count_optimal:=0;

  // TODO: Если кол-во элементов в массиве = 1 (а это довольно часто!), то смысла в переборе нету
  // не так. сейчас перебора как такового нет, выбирается максимальный размер BB и по этой оси
  // далается сечение. но по идее в некоторых вариантах придется выбирать
  isVeryOptimal:=False;
  testSeparatorCount:=TEntsManipulator.GetTestNodesCount-1;
  for i:=0 to TEntsManipulator.GetTestNodesCount-1 do begin
    TEntsManipulator.CreateSeparator(BoundingBox,TestNode,PFirstStageData,i);

    pobj:=nul.beginiterate(ir);
    if pobj<>nil then begin
      plus_count:=0;
      minus_count:=0;
      nul_count:=0;
      repeat
        pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
        ep:=TEntsManipulator.GetBBPosition(TestNode.plane,TEntsManipulator.GetEntityBoundingBox(pobj^));
        case ep of
          TEP_Plus:Inc(plus_count,TEntsManipulator.EntitySizeOrOne(pobj^));
          TEP_Minus:Inc(minus_count,TEntsManipulator.EntitySizeOrOne(pobj^));
          TEP_nul:Inc(nul_count,TEntsManipulator.EntitySizeOrOne(pobj^));
        end;
        pobj:=nul.iterate(ir);
      until pobj=nil;

      //вариант единственный, его и выбираем
      if testSeparatorCount=0 then begin
        plus_count_optimal:=plus_count;
        minus_count_optimal:=minus_count;
        nul_count_optimal:=nul_count;
        plane_optimal:=TestNode.plane;
        Break;
      end;

      //вариант не единственный, выбираем лучший перебирая все,
      //или берем сразу тот который показался лучшим isVeryOptimal
      if IsOptimalTestNode then begin
        plus_count_optimal:=plus_count;
        minus_count_optimal:=minus_count;
        nul_count_optimal:=nul_count;
        plane_optimal:=TestNode.plane;
        if isVeryOptimal then
          Break;
      end;
    end;
  end;

  // сохранение оптимального
  nul_optimal.init(nul_count_optimal);

  if plus_count_optimal>0 then begin
    if pplusnode=nil then begin
      Getmem(pointer(pplusnode),sizeof(GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,
        TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>));
      pplusnode.initnul;
    end;
    pplusnode.lock;
    pplusnode.root:=@self;
    pplusnode.setsize(plus_count_optimal);
  end;

  if minus_count_optimal>0 then begin
    if pminusnode=nil then begin
      Getmem(pointer(pminusnode),sizeof(GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,
      TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>));
      pminusnode.initnul;
    end;
    pminusnode.lock;
    pminusnode.root:=@self;
    pminusnode.setsize(minus_count_optimal);
  end;

  pobj:=nul.beginiterate(ir);
  if pobj<>nil then begin
    repeat
      pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
      ep:=TEntsManipulator.GetBBPosition(plane_optimal,TEntsManipulator.GetEntityBoundingBox(pobj^));
      case ep of
        TEP_Plus:if plus_count_optimal>0 then
            pplusnode.AddObjectToNodeTree(pobj^);
        TEP_Minus:if minus_count_optimal>0 then
            pminusnode.AddObjectToNodeTree(pobj^);
        TEP_nul:TEntsManipulator.StoreEntityToArray(pobj^,nul_optimal);
      end;
      pobj:=nul.iterate(ir);
    until pobj=nil;
  end;

  temp_entarr:=nul;
  nul:=nul_optimal;

  temp_entarr.Clear;
  temp_entarr.done;

  Separator:=plane_optimal;

  if plus_count_optimal>0 then
    pplusnode.unlock;
  if minus_count_optimal>0 then
    pminusnode.unlock;

  updateenttreeadress;
  NodeData.AfterSeparateNode(nul);
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.AddObjectToNodeTree(var Entity:TEntity);
begin
  AddObjToNul(Entity);
  if (nul.Count<>1)or(pplusnode<>nil)or(pminusnode<>nil) then
    CorrectNodeBoundingBox(Entity)
  else
    BoundingBox:=TEntsManipulator.GetEntityBoundingBox(Entity);
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.SetSize(ns:integer);
begin
  TEntsManipulator.SetSizeInArray(ns,nul);
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.CorrectNodeBoundingBox(var AEntity:TEntity;
  ASetToThis:boolean=False);
begin
  if ASetToThis then
    BoundingBox:=TEntsManipulator.GetEntityBoundingBox(AEntity)
  else
    TEntsManipulator.CorrectNodeBoundingBox(BoundingBox,AEntity);
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.updateenttreeadress;
var
  pobj:PTEntity;
  ir:itrec;
begin
  pobj:=nul.beginiterate(ir);
  if pobj<>nil then
    repeat
      pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
      TEntsManipulator.StoreTreeAdressInOnject(pobj^,self,ir.itc);
           {pobj^.bp.TreePos.Owner:=@self;
           pobj^.bp.TreePos.SelfIndex:=ir.itc;}

      pobj:=nul.iterate(ir);
    until pobj=nil;
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.AddObjToNul(var Entity:TEntity);
var
  index:integer;
begin
  index:=TEntsManipulator.StoreEntityToArray(Entity,nul);
  //index:=nul.PushBackData(@Entity);
  TEntsManipulator.StoreTreeAdressInOnject(Entity,self,index);
     {Entity.bp.TreePos.Owner:=@self;
     Entity.bp.TreePos.SelfIndex:=index;}
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.initnul;
begin
  nul.init(50);
  pplusnode:=nil;
  pminusnode:=nil;
  NodeData.CreateDef;
  LockCounter:=0;
  //NodeData.FulDraw:={True}TDTFulDraw;
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.Shrink;
begin
  nul.shrink;
  if assigned(pplusnode) then
    pplusnode^.shrink;
  if assigned(pminusnode) then
    pminusnode^.shrink;
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.ClearSub;
begin
  Separator:=default(TSeparator);
  BoundingBox:=default(TBoundingBox);
  //NodeDir:TNodeDir;
  Root:=nil;
  NodeData.Clear;
  nul.Clear;
  if assigned(pplusnode) then begin
    pplusnode^.done;
    Freemem(pointer(pplusnode));
    pplusnode:=nil;
  end;
  if assigned(pminusnode) then begin
    pminusnode^.done;
    Freemem(pointer(pminusnode));
    pminusnode:=nil;
  end;
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.MoveSub(var node:GZBInarySeparatedGeometry<TBoundingBox,
    TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>);
begin
  if @nul<>@node.nul then begin
    nul.copyto(node.nul);
    nul.Clear;
  end;
  if assigned(pplusnode) then begin
    pplusnode^.MoveSub(node);
    pplusnode^.done;
    Freemem(pointer(pplusnode));
    pplusnode:=nil;
  end;
  if assigned(pminusnode) then begin
    pminusnode^.MoveSub(node);
    pminusnode^.done;
    Freemem(pointer(pminusnode));
    pminusnode:=nil;
  end;
  NodeData.Destroy;
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,
  TEntityArrayIterateResult,TEntityArray>.done;
begin
  ClearSub;
  nul.done;
  NodeData.Destroy;
end;

begin
end.

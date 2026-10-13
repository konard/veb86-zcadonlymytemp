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

unit uzeGeometryTypes;
{$Mode delphi}{$ModeSwitch advancedrecords}{$ModeSwitch typehelpers}{$H+}
{$Macro on}

interface

uses
  uzbLogIntf{$if FPC_FULLVERSION<30205},math{$endif};

resourcestring
  rsDivByZero='Divide by zero';

const
  EPSILON2=1e-30;
  eps=1e-14;
  floateps=1e-6;
  sqreps=1e-7;
  bigeps=1e-10;
  dbl_dig=15;
  tenEdbl_dig=1000000000000000;
type
  TzeMatrixType=(MTIdentity,MTScale,MTTranslate,MTRotate,MTShear);
  TzeMatrixTypes=set of TzeMatrixType;

  GMatrix4<TMtr>=record
    mtr:TMtr;
    t:TzeMatrixTypes;
    constructor CreateRec(AMtr:TMtr;At:TzeMatrixTypes);
    function IsIdentity:boolean;inline;
  end;
  GVector4<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>=record
    {$Define VectorTypeName := GVector4}
    {$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}{$Define HAS_W}
    {$Include gvectorintf.inc}
    {$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}{$UnDef HAS_W}
    {$UnDef VectorTypeName}
  end;
  GVector3<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>=record
    {$Define VectorTypeName := GVector3}
    {$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}
    {$Include gvectorintf.inc}
    {$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}
    {$UnDef VectorTypeName}
  end;
  GVector2<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>=record
    {$Define VectorTypeName := GVector2}
    {$Define HAS_X}{$Define HAS_Y}
    {$Include gvectorintf.inc}
    {$UnDef HAS_X}{$UnDef HAS_Y}
    {$UnDef VectorTypeName}
  end;
  GVector4i<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>=record
    {$Define VectorTypeName := GVector4i}
    {$Define IntParam}
    {$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}{$Define HAS_W}
    {$Include gvectorintf.inc}
    {$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}{$UnDef HAS_W}
    {$UnDef IntParam}
    {$UnDef VectorTypeName}
  end;
  GVector3i<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>=record
    {$Define VectorTypeName := GVector3i}
    {$Define IntParam}
    {$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}
    {$Include gvectorintf.inc}
    {$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}
    {$UnDef IntParam}
    {$UnDef VectorTypeName}
  end;
  GVector2i<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>=record
    {$Define VectorTypeName := GVector2i}
    {$Define IntParam}
    {$Define HAS_X}{$Define HAS_Y}
    {$Include gvectorintf.inc}
    {$UnDef HAS_X}{$UnDef HAS_Y}
    {$UnDef IntParam}
    {$UnDef VectorTypeName}
  end;


  GPoint3<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>=record
    {$Define PointTypeName := GPoint3}
    {$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}
    {$Include gpointintf.inc}
    {$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}
    {$UnDef PointTypeName}
  end;
  GPoint2<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>=record
    {$Define PointTypeName := GPoint2}
    {$Define HAS_X}{$Define HAS_Y}
    {$Include gpointintf.inc}
    {$UnDef HAS_X}{$UnDef HAS_Y}
    {$UnDef PointTypeName}
  end;
  GPoint2i<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>=record
    {$Define PointTypeName := GPoint2i}
    {$Define IntParam}
    {$Define HAS_X}{$Define HAS_Y}
    {$Include gpointintf.inc}
    {$UnDef HAS_X}{$UnDef HAS_Y}
    {$UnDef IntParam}
    {$UnDef PointTypeName}
  end;

  PTZeDimLess=^TZeDimLess;
  TZeDimLess=type Double;

  PTZeAngle=^TZeAngle;
  TZeAngle=type Double;


  TzeXUnits=Double;
  TzeYUnits=Double;
  TzeZUnits=Double;

  //TDummyVector=record end;
  TDummy1d=record x:double end;
  TDummy1s=record x:single end;
  TDummy1i=record x:integer end;

  TzeVector2d=GVector2<double,double{$if FPC_FULLVERSION<30205},double{$endif}>;
  PzeVector2d=^TzeVector2d;

  TzeVector3d=GVector3<double,TzeVector2d{$if FPC_FULLVERSION<30205},double{$endif}>;
  PzeVector3d=^TzeVector3d;

  TzeVector4d=GVector4<double,TzeVector3d{$if FPC_FULLVERSION<30205},double{$endif}>;
  PzeVector4d=^TzeVector4d;

  TzeVector2s=GVector2<single,single{$if FPC_FULLVERSION<30205},single{$endif}>;
  PzeVector2s=^TzeVector2s;

  TzeVector3s=GVector3<single,TzeVector2s{$if FPC_FULLVERSION<30205},single{$endif}>;
  PzeVector3s=^TzeVector3s;

  TzeVector4s=GVector4<single,TzeVector3s{$if FPC_FULLVERSION<30205},single{$endif}>;
  PzeVector4s=^TzeVector4s;

  TzeVector2i=GVector2i<integer,integer{$if FPC_FULLVERSION<30205},integer{$endif}>;
  PzeVector2i=^TzeVector2i;

  TzeVector3i=GVector3i<integer,TzeVector2i{$if FPC_FULLVERSION<30205},integer{$endif}>;
  PzeVector3i=^TzeVector3i;

  TzeVector4i=GVector4i<integer,TzeVector3i{$if FPC_FULLVERSION<30205},integer{$endif}>;
  PzeVector4i=^TzeVector4i;


  TzePoint2d=GPoint2<double,TDummy1d{$if FPC_FULLVERSION<30205},double{$endif},TzeVector2d>;
  PzePoint2d=^TzePoint2d;

  TzePoint3d=GPoint3<double,TzePoint2d{$if FPC_FULLVERSION<30205},double{$endif},TzeVector3d>;
  PzePoint3d=^TzePoint3d;

  TzePoint2s=GPoint2<single,TDummy1s{$if FPC_FULLVERSION<30205},single{$endif},TzeVector2s>;
  PzePoint2s=^TzePoint2s;

  TzePoint3s=GPoint3<single,TzePoint2s{$if FPC_FULLVERSION<30205},single{$endif},TzeVector3s>;
  PzePoint3s=^TzePoint3s;

  TzePoint2i=GPoint2i<integer,TDummy1i{$if FPC_FULLVERSION<30205},integer{$endif},TzeVector2i>;
  PzePoint2i=^TzePoint2i;


  {$if FPC_FULLVERSION >=30205}
  GRawMatrix4<GRow>=record
    case Integer of
      0:(l0,l1,l2,l3:GRow);
      1:(v:array [0..3] of GRow);
  end;
  GRawMatrix6<GRow>=record
    case Integer of
      0:(right,left,down,up,near,far:GRow);
      1:(v:array [0..5] of GRow);
  end;
  TzeFrustum=GRawMatrix6<TzeVector4d>;
  TzeMatrix4s=GRawMatrix4<TzeVector4s>;
  TzeMatrix4d=GRawMatrix4<TzeVector4d>;
  {$else}
  TzeFrustum=record
    case Integer of
      0:(right,left,down,up,near,far:TzeVector4d);
      1:(v:array [0..5] of TzeVector4d);
  end;
  TzeMatrix4s=record
    case Integer of
      0:(l0,l1,l2,l3:TzeVector4s);
      1:(v:array [0..3] of TzeVector4s);
  end;
  TzeMatrix4d=record
    case Integer of
      0:(l0,l1,l2,l3:TzeVector4d);
      1:(v:array [0..3] of TzeVector4d);
  end;
  {$endif}

  TzeTypedMatrix4d=GMatrix4<TzeMatrix4d>;
  TzeTypedMatrix4s=GMatrix4<TzeMatrix4s>;

  PzeTypedMatrix4d=^TzeTypedMatrix4d;
  PzeTypedMatrix4s=^TzeTypedMatrix4s;

  TzeQuaternion=record
    ImagPart:TzeVector3d;
    RealPart:double;
  end;
  PzeQuaternion=^TzeQuaternion;


  GDBBasis=record
    ox:TzeVector3d;
    oy:TzeVector3d;
    oz:TzeVector3d;
  end;

  GDBObj2dprop=record
    Basis:GDBBasis;
    P_insert:TzePoint3d;
  end;
  PGDBObj2dprop=^GDBObj2dprop;

  PGDBLineProp=^GDBLineProp;
  GDBLineProp=record
    lBegin:TzePoint3d;
    lEnd:TzePoint3d;
  end;

  FontFloat=Double;
  PFontFloat=^FontFloat;
  TzeVector2FontFloat=GVector2<FontFloat,FontFloat{$if FPC_FULLVERSION<30205},FontFloat{$endif}>;
  PzeVector2FontFloat=^TzeVector2FontFloat;

  TzePoint2FontFloat=GPoint2<FontFloat,TDummy1d{$if FPC_FULLVERSION<30205},FontFloat{$endif},TzeVector2FontFloat>;

  GDBPolyVertex2D=record
    coord:TzePoint2d;
    count:Integer;
  end;
  PGDBPolyVertex2D=^GDBPolyVertex2D;

  tmatrixs=record
    pmodelMatrix:PzeTypedMatrix4d;
    pprojMatrix:PzeTypedMatrix4d;
    pviewport:PzeVector4i;
  end;

  {Bounding volume}
  GAABoundingVolume<GVecType,GCoordType>=record
  type
    Tself=GAABoundingVolume<GVecType,GCoordType>;
  var
    pMin:GVecType;
    pMax:GVecType;
    constructor Make(const AMinPt,AMaxPt:GVecType);
    constructor MakeFrom2Pt(const APt1,APt2:GVecType);
    constructor Fill(const AValue:GVecType);overload;
    constructor Fill(const AMinValue,AMaxValue:GCoordType);overload;
    procedure Concat(const APoint:GVecType);
    function IsZero:boolean;
    function IsNull:boolean;
    procedure CheckAndConcat(const ASecAABV:Tself);
    class operator *(const l:TSelf;r:GCoordType):TSelf;inline;
    function IsContainsPoint(const APoint:GVecType):boolean;
    function IsIntersectWith(const ABV:Tself):boolean;
  end;

  TBoundingBox=GAABoundingVolume<TzePoint3d,TzePoint3d.TCoordType>;
  TBoundingRect=GAABoundingVolume<TzePoint2d,TzePoint2d.TCoordType>;

  TInBoundingVolume=(IRFully,IRPartially,IREmpty,IRNotAplicable);
  OutBound4V=packed array [0..3]of TzePoint3d;
  PGDBQuad3d=^GDBQuad3d;
  GDBQuad2d=packed array[0..3] of TzePoint2d;
  GDBQuad3d=OutBound4V;
  tarcrtmodify=record
    p1,p2,p3:TzePoint2d;
  end;
  ptarcrtmodify=^tarcrtmodify;

  TArcData=record
    r,startangle,endangle:Double;
    p:TzePoint2d;
  end;

  TzeVector4dHlpr=type helper for TzeVector4d
    function asVector4s:TzeVector4s;inline;
  end;
  TzeVector3dHlpr=type helper for TzeVector3d
    function asPoint3d:TzePoint3d;inline;
    function asVector3s:TzeVector3s;inline;
  end;
  TzeVector3sHlpr=type helper for TzeVector3s
    function asPoint3s:TzePoint3s;inline;
  end;
  TzePoint3dHlpr=type helper for TzePoint3d
    //function asVector3d:TzeVector3d;inline;
    function asPoint3s:TzePoint3s;inline;
  end;
  TzeVector2dHlpr=type helper for TzeVector2d
    function asPoint2d:TzePoint2d;inline;
  end;
  TzePoint2DHlpr=type helper for TzePoint2d
    //function asVector2d:TzeVector2d;inline;
    function asPoint3d:TzePoint3d;inline;
    function asPoint2i:TzePoint2i;inline;
  end;

  TzeTypedMatrix4dHlpr=type helper for TzeTypedMatrix4d
    function ToTypedMatrix4s:TzeTypedMatrix4s;inline;
  end;

  InterceptProp<T>=record
    private
      FisIntercept:Boolean;//**< Есть это пересение или нет
      FInterceptCoord:T;   //**< Точка пересечения X,Y,Z
      Ft1,Ft2:Double;      //**< позиция на линии 1 и 2 в виде относительных цифр от 0 до 1
    Public
      Property isIntercept:Boolean read FisIntercept write FisIntercept;
      Property InterceptCoord:T read FInterceptCoord write FInterceptCoord;
      Property t1:Double read Ft1 write Ft1;
      Property t2:Double read Ft2 write Ft2;
  end;

  Intercept3DProp=InterceptProp<TzePoint3d>;

  Intercept2DProp=InterceptProp<TzePoint2d>;

  TDistWitht=record
    t,d:double;
  end;
  TCSDir=(TCSDLeft,TCSDRight);

const
 CMTScale=[MTIdentity,MTScale];
 CMTTranslate=[MTIdentity,MTTranslate];
 CMTRotate=[MTIdentity,MTRotate];
 CMTTransform=[MTIdentity,MTScale,MTTranslate,MTRotate];
 CMTIdentity=[MTIdentity];
 CMTShear=[MTShear];

implementation

constructor GAABoundingVolume<GVecType,GCoordType>.Make(const AMinPt,AMaxPt:GVecType);
begin
  pMin:=AMinPt;
  pMax:=AMaxPt;
end;
constructor GAABoundingVolume<GVecType,GCoordType>.MakeFrom2Pt(const APt1,APt2:GVecType);
begin
  pMin:=APt1;
  pMin.ConcatFromMinSide(Apt2);
  pMax:=APt1;
  pMax.ConcatFromMaxSide(Apt2);
end;

constructor GAABoundingVolume<GVecType,GCoordType>.Fill(const AValue:GVecType);
begin
  pMin:=AValue;
  pMax:=AValue;
end;
constructor GAABoundingVolume<GVecType,GCoordType>.Fill(const AMinValue,AMaxValue:GCoordType);
begin
  pMin.fill(AMinValue);
  pMax.fill(AMaxValue);
end;


procedure GAABoundingVolume<GVecType,GCoordType>.Concat(const APoint:GVecType);
begin
  pMin.ConcatFromMinSide(APoint);
  pMax.ConcatFromMaxSide(APoint);
end;
function GAABoundingVolume<GVecType,GCoordType>.IsZero:boolean;
begin
  result:=pMin.isTrueEqual(pMax);
end;

function GAABoundingVolume<GVecType,GCoordType>.IsNull:boolean;
begin
  Result:=(pMin-pMax).IsNul(eps);
end;

procedure GAABoundingVolume<GVecType,GCoordType>.CheckAndConcat(const ASecAABV:Tself);
begin
  if IsZero then begin
    self:=ASecAABV;
  end else if not ASecAABV.IsZero then begin
    Concat(ASecAABV.pMin);
    Concat(ASecAABV.pMax);
  end;
end;

class operator GAABoundingVolume<GVecType,GCoordType>.*(const l:TSelf;r:GCoordType):TSelf;
var
  p:GVecType;
  v:GVecType;
begin
  p:=(l.pMax+l.pMin.asVector)/2;
  v.asvector:=(l.pMax-p)*r;
  Result.pMin:=p-v.asvector;
  Result.pMax:=p+v.asvector;
end;

function GAABoundingVolume<GVecType,GCoordType>.IsContainsPoint(const APoint:GVecType):boolean;
begin
  result:=pMin.LessOrEqual(APoint) and pMax.GreaterOrEqual(APoint);
end;

function GAABoundingVolume<GVecType,GCoordType>.IsIntersectWith(const ABV:Tself):boolean;
var
  b1,b2,b1c,b2c:GVecType;
  dist:GVecType;
begin
  //половина диагонали первого бокса
  b1.asVector:=(pMax-pMin)/2;
  //половина диагонали второго бокса
  b2.asVector:=(ABV.pMax-ABV.pMin)/2;
  //центры боксов
  b1c:=pMin+b1.asVector;
  b2c:=ABV.pMin+b2.asVector;
  //расстояние между центрами
  dist.asVector:=(b1c-b2c).EWAbsed;
  //пересечение боксов
  Result:=false;

  if (b1+(b2-dist)).isBiggerEW(-bigeps) then
    Result:=true;

  {if (((b1.x+b2.x)-dist.x)>-bigeps)  and(((b1.y+b2.y)-dist.y)>-bigeps)  and(((b1.z+b2.z)-dist.z)>-bigeps) then
    Result:=true;}
end;

{$Define VectorTypeName := GVector4}
{$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}{$Define HAS_W}
{$Include gvectorimpl.inc}
{$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}{$UnDef HAS_W}
{$UnDef VectorTypeName}

{$Define VectorTypeName := GVector3}
{$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}
{$Include gvectorimpl.inc}
{$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}
{$UnDef VectorTypeName}

{$DEFINE VectorTypeName := GVector2}
{$Define HAS_X}{$Define HAS_Y}
{$Include gvectorimpl.inc}
{$UnDef HAS_X}{$UnDef HAS_Y}
{$UnDef VectorTypeName}

{$Define VectorTypeName := GVector4i}
{$Define IntParam}
{$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}{$Define HAS_W}
{$Include gvectorimpl.inc}
{$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}{$UnDef HAS_W}
{$UnDef IntParam}
{$UnDef VectorTypeName}

{$Define VectorTypeName := GVector3i}
{$Define IntParam}
{$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}
{$Include gvectorimpl.inc}
{$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}
{$UnDef IntParam}
{$UnDef VectorTypeName}

{$DEFINE VectorTypeName := GVector2i}
{$Define IntParam}
{$Define HAS_X}{$Define HAS_Y}
{$Include gvectorimpl.inc}
{$UnDef HAS_X}{$UnDef HAS_Y}
{$UnDef IntParam}
{$UnDef VectorTypeName}


{$Define PointTypeName := GPoint3}
{$Define HAS_X}{$Define HAS_Y}{$Define HAS_Z}
{$Include gpointimpl.inc}
{$UnDef HAS_X}{$UnDef HAS_Y}{$UnDef HAS_Z}
{$UnDef PointTypeName}

{$DEFINE PointTypeName := GPoint2}
{$Define HAS_X}{$Define HAS_Y}
{$Include gpointimpl.inc}
{$UnDef HAS_X}{$UnDef HAS_Y}
{$UnDef PointTypeName}

{$DEFINE PointTypeName := GPoint2i}
{$Define IntParam}
{$Define TwoDimension}
{$Define HAS_X}{$Define HAS_Y}
{$Include gpointimpl.inc}
{$UnDef HAS_X}{$UnDef HAS_Y}
{$UnDef TwoDimension}
{$UnDef IntParam}
{$UnDef PointTypeName}

function TzeVector4dHlpr.asVector4s:TzeVector4s;
begin
  with TzeVector4s((@result)^) do// Этот хак убирает по одной лишней инструкции с каждого присвоения
  begin                          // возможно в будущем, это можно будет убрать, когда компилятор
                                 // сможет сам это оптимизировать
    v[0]:=self.v[0];
    v[1]:=self.v[1];
    v[2]:=self.v[2];
    v[3]:=self.v[3];
  end;

  //result.v[0]:=v[0];
  //result.v[1]:=v[1];
  //result.v[2]:=v[2];
  //result.v[3]:=v[3];

  //Result.x:=x;
  //Result.y:=y;
  //Result.z:=z;
  //Result.w:=w;
end;

function TzeVector3dHlpr.asPoint3d:TzePoint3d;
begin
  result:=TzePoint3d(self);
end;

function TzeVector3dHlpr.asVector3s:TzeVector3s;inline;
begin
  Result.x:=x;
  Result.y:=y;
  Result.z:=z;
end;

function TzeVector3sHlpr.asPoint3s:TzePoint3s;
begin
  result:=TzePoint3s(self);
end;

{function TzePoint3dHlpr.asVector3d:TzeVector3d;
begin
  result:=TzeVector3d(self);
end;}

function TzePoint3dHlpr.asPoint3s:TzePoint3s;
begin
  Result.x:=x;
  Result.y:=y;
  Result.z:=z;
end;

function TzeVector2dHlpr.asPoint2d:TzePoint2d;
begin
  result:=TzePoint2d(self);
end;

{function TzePoint2DHlpr.asVector2d:TzeVector2d;
begin
  result:=TzeVector2d(self);
end;}

function TzePoint2DHlpr.asPoint3d:TzePoint3d;
begin
  result.x:=x;
  result.y:=y;
  result.z:=0;
end;

function TzePoint2DHlpr.asPoint2i:TzePoint2i;
begin
  result.x:=round(x);
  result.y:=round(y);
end;

constructor GMatrix4<TMtr>.CreateRec(AMtr:TMtr;At:TzeMatrixTypes);
begin
  mtr:=AMtr;
  t:=At;
end;
function GMatrix4<TMtr>.IsIdentity:Boolean;
begin
  result:=(t=CMTIdentity);
end;

function TzeTypedMatrix4dHlpr.ToTypedMatrix4s:TzeTypedMatrix4s;
begin
  result.mtr.l0:=mtr.l0.asVector4s;
  result.mtr.l1:=mtr.l1.asVector4s;
  result.mtr.l2:=mtr.l2.asVector4s;
  result.mtr.l3:=mtr.l3.asVector4s;
  result.t:=t;
end;

end.

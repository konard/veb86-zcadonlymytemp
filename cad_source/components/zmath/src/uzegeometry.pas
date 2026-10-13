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

unit uzeGeometry;
{$Mode objfpc}{$ModeSwitch advancedrecords}{$ModeSwitch typehelpers}{$H+}
{Inline off}

interface
uses
  SysUtils,Math,
  uzeGeometryTypes,uzbLogIntf;

const
  cEmptyMtr:TzeMatrix4d=(v:((v:(0,0,0,0)),
    (v:(0,0,0,0)),
    (v:(0,0,0,0)),
    (v:(0,0,0,0))));
  cOneMtr:TzeMatrix4d=(v:((v:(1,0,0,0)),
    (v:(0,1,0,0)),
    (v:(0,0,1,0)),
    (v:(0,0,0,1))));
  cEmptyMatrix:TzeTypedMatrix4d=(mtr:(v:((v:(0,0,0,0)),
    (v:(0,0,0,0)),
    (v:(0,0,0,0)),
    (v:(0,0,0,0))));
    t:[]);
  cOneMatrix:TzeTypedMatrix4d=(mtr:(v:((v:(1,0,0,0)),
    (v:(0,1,0,0)),
    (v:(0,0,1,0)),
    (v:(0,0,0,1))));
    t:CMTIdentity);

  cRightAngle=pi/2;
  cIdentityQuaternion:TzeQuaternion=(ImagPart:(x:0;y:0;z:0);RealPart:1);
  cxAxisIndex=0;
  cyAxisIndex=1;
  czAxisIndex=2;
  cwAxisIndex=3;

  cV3d__0__0__0:TzeVector3d=(x:0;y:0;z:0);
  cV3d__1__0__0:TzeVector3d=(x:1;y:0;z:0);
  cV3d_m1__0__0:TzeVector3d=(x:-1;y:0;z:0);
  cV3d__0__1__0:TzeVector3d=(x:0;y:1;z:0);
  cV3d__0__0__1:TzeVector3d=(x:0;y:0;z:1);
  cV3d__0__0_m1:TzeVector3d=(x:0;y:0;z:-1);
  cV3d__1__1__1:TzeVector3d=(x:1;y:1;z:1);
  cV3d__1__1__0:TzeVector3d=(x:1;y:1;z:0);
  cV3d_m1__1__0:TzeVector3d=(x:-1;y:1;z:0);
  cV3d_m1_m1_m1:TzeVector3d=(x:-1;y:-1;z:-1);

  cP3d__0__0__0:TzePoint3d=(x:0;y:0;z:0);
  cP3d__1__0__0:TzePoint3d=(x:1;y:0;z:0);
  cP3d__1__1__1:TzePoint3d=(x:1;y:1;z:1);
  cP3d_m1__0__0:TzePoint3d=(x:-1;y:1;z:1);
  cP3d__0__0_m1:TzePoint3d=(x:0;y:0;z:-1);
  cP3d__0__0__1:TzePoint3d=(x:0;y:0;z:1);
  cP3d__0__1__0:TzePoint3d=(x:0;y:1;z:0);
  cP3d__0_m1__0:TzePoint3d=(x:0;y:-1;z:0);
  cP3d_m1_m1_m1:TzePoint3d=(x:-1;y:-1;z:-1);
  cP3d_mInf_mnf_mInf:TzePoint3d=(x:NegInfinity;y:NegInfinity;z:NegInfinity);
  cP3d_Inf_nf_Inf:TzePoint3d=(x:Infinity;y:Infinity;z:Infinity);

  cV4d__0__0__0__1:TzeVector4d=(x:0;y:0;z:0;w:1);
  cV4d__0__0__0__0:TzeVector4d=(v:(0,0,0,0));
  cV4d__1__0__0__1:TzeVector4d=(v:(1,0,0,1));
  cV4d__0__1__0__1:TzeVector4d=(v:(0,1,0,1));
  cV4d__0__0__1__1:TzeVector4d=(v:(0,0,1,1));

  cV3s__0__0__0:TzeVector3s=(x:0;y:0;z:0);
  cP3s__0__0__0:TzePoint3s=(x:0;y:0;z:0);

  cV2d__0__0:TzeVector2d=(x:0;y:0);
  cV2d__0__1:TzeVector2d=(x:0;y:1);
  cV2d__1__0:TzeVector2d=(x:1;y:0);

  cP2d__0__0:TzePoint2d=(x:0;y:0);

  cBBNul:TBoundingBox=(pMin:(x:0;y:0;z:0);pMax:(x:0;y:0;z:0));

function VectorAngle(const AVector:TzeVector2d):double;
function TwoVectorAngle(const Vector1,Vector2:TzeVector3d):double;//inline;

function MatrixMultiply(const M1,M2:TzeTypedMatrix4d):TzeTypedMatrix4d;overload;inline;
function MatrixMultiply(const M1:TzeTypedMatrix4d;const M2:TzeTypedMatrix4s):TzeTypedMatrix4d;overload;inline;
function MatrixMultiplyF(const M1,M2:TzeTypedMatrix4d):TzeTypedMatrix4s;inline;

procedure MatrixTranspose(var M:TzeTypedMatrix4d);overload;inline;
procedure MatrixTranspose(var M:TzeTypedMatrix4s);overload;inline;
procedure MatrixNormalize(var M:TzeTypedMatrix4d);inline;
procedure MatrixInvert(var M:TzeTypedMatrix4d);inline;

function CreateRotationMatrixX(const angle:double):TzeTypedMatrix4d;inline;
function CreateRotationMatrixY(const angle:double):TzeTypedMatrix4d;inline;
function CreateRotationMatrixZ(const angle:double):TzeTypedMatrix4d;inline;
function CreateRotatedXVector(const angle:double):TzeVector3d;inline;
function CreateRotatedYVector(const angle:double):TzeVector3d;inline;
function CreateAffineRotationMatrix(const anAxis:TzeVector3d;angle:double):TzeTypedMatrix4d;overload;inline;
function CreateAffineRotationMatrix(const AAxis,ARefV,AV:TzeVector3d):TzeTypedMatrix4d;overload;inline;
function CreateTranslationMatrix(const _V:TzeVector3d):TzeTypedMatrix4d;inline;overload;
function CreateTranslationMatrix(const tx,ty,tz:double):TzeTypedMatrix4d;inline;overload;
function CreateScaleMatrix(const V:TzeVector3d):TzeTypedMatrix4d;inline;overload;
function CreateScaleMatrix(const s:double):TzeTypedMatrix4d;inline;overload;
function CreateScaleMatrix(const sx,sy,sz:double):TzeTypedMatrix4d;inline;overload;
function CreateReflectionMatrix(const plane:TzeVector4d):TzeTypedMatrix4d;



function VectorTransform(const V:TzeVector4d;const M:TzeTypedMatrix4d):TzeVector4d;overload;inline;
function VectorTransform(const V:TzeVector4d;const M:TzeTypedMatrix4s):TzeVector4d;overload;inline;
function VectorTransform(const V:TzeVector4s;const M:TzeTypedMatrix4s):TzeVector4s;overload;inline;

function VectorTransform2D(const V:TzePoint2d;const M:TzeTypedMatrix4d):TzePoint3d;overload;inline;
function VectorTransform3D(const V:TzePoint3d;const M:TzeTypedMatrix4d):TzePoint3d;overload;inline;
function VectorTransform3D(const V:TzeVector3d;const M:TzeTypedMatrix4d):TzeVector3d;overload;inline;
function VectorTransform3D(const V:TzePoint3d;const M:TzeTypedMatrix4s):TzePoint3d;overload;inline;
function VectorTransform3D(const V:TzePoint3s;const M:TzeTypedMatrix4d):TzePoint3s;overload;inline;
function VectorTransform3D(const V:TzePoint3s;const M:TzeTypedMatrix4s):TzePoint3s;overload;inline;

function FrustumTransform(const frustum:TzeFrustum;const M:TzeTypedMatrix4d;
  MatrixAlreadyTransposed:boolean=False):TzeFrustum;overload;inline;
function FrustumTransform(const frustum:TzeFrustum;const M:TzeTypedMatrix4s;
  MatrixAlreadyTransposed:boolean=False):TzeFrustum;overload;inline;

function distance2piece(const q,p1,p2:TzePoint3d):double;overload;inline;

function distance2piece_2Dmy(const q:TzePoint2d;const p1,p2:TzePoint2d):double;inline;

function distance2ray(const q:TzePoint3d;const p1,p2:TzePoint3d):TDistWitht;

function CreateVertexFromArray(var counter:integer;const args:array of const):TzePoint3d;
function CreateVertex2DFromArray(var counter:integer;const args:array of const):TzePoint2d;
function CreateDoubleFromArray(var counter:integer;const args:array of const):double;
function CreateStringFromArray(var counter:integer;const args:array of const):string;
function CreateBooleanFromArray(var counter:integer;const args:array of const):boolean;

//function IsPointInBB(const point,LBN,RTF:TzePoint3d):boolean;overload;inline;
//function IsPointInBB(const point:TzePoint3d;const fistbb:TBoundingBox):boolean;overload;inline;
//function CreateBBFrom2Point(const p1,p2:TzePoint3d):TBoundingBox;
//function CreateBfrBFromPoint(const p:TzePoint3d):TBoundingBox;inline;
//procedure ConcatBB(var fistbb:TBoundingBox;const secbb:TBoundingBox);inline;
//procedure concatBBandPoint(var fistbb:TBoundingBox;const point:TzePoint3d);inline;
//function IsBBNul(const bb:TBoundingBox):boolean;overload;inline;
//function boundingintersect(const bb1,bb2:TBoundingBox):boolean;inline;
//function ScaleBB(const bb:TBoundingBox;const k:double):TBoundingBox;

function VectorDot(const v1,v2:TzeVector3d):TzeVector3d;inline;
function ScalarDot(const v1,v2:TzeVector3d):double;inline;
function SQRdist_Point_to_Segment(const p:TzePoint3d;const s0,s1:TzePoint3d):double;inline;
function NearestPointOnSegment(const p:TzePoint3d;const s0,s1:TzePoint3d):TzePoint3d;inline;

//проверка вектора на близость к оси Z (координаты x и y меньше 1/64
//используется для Arbitrary Axis Algorithm (DXF)
function IsNearToZ(const v:TzeVector3d):boolean;inline;
function IsValidRange(const d1,d2:Double):boolean;inline;

procedure _myGluProject(const objx,objy,objz:Double;const modelMatrix,projMatrix:PzeTypedMatrix4d;
  const viewport:PzeVector4i; out winx,winy,winz:Double);inline;
procedure _myGluProject2(const objcoord:TzePoint3d;const modelMatrix,projMatrix:PzeTypedMatrix4d;
  const viewport:PzeVector4i; out wincoord:TzePoint3d);inline;
procedure _myGluUnProject(const winx,winy,winz:Double;const modelMatrix,projMatrix:PzeTypedMatrix4d;
  const viewport:PzeVector4i;out objx,objy,objz:Double);inline;

function Ortho(const xmin,xmax,ymin,ymax,zmin,zmax:Double;const matrix:PzeTypedMatrix4d):TzeTypedMatrix4d;{inline;}
function Perspective(const fovy,W_H,zmin,zmax:Double;const matrix:PzeTypedMatrix4d):TzeTypedMatrix4d;inline;
function LookAt(point:TzePoint3d;ex,ey,ez:TzeVector3d;const matrix:PzeTypedMatrix4d):TzeTypedMatrix4d;inline;

function calcfrustum(const clip:PzeTypedMatrix4d):TzeFrustum;inline;
function PointOf3PlaneIntersect(const P1,P2,P3:TzeVector4d):TzePoint3d;inline;
function PointOfRayPlaneIntersect(const p1:TzePoint3d;const d:TzeVector3d;const plane:TzeVector4d;
  out point :TzePoint3d):Boolean;overload;inline;
function PointOfRayPlaneIntersect(const p1:TzePoint3d;const d:TzeVector3d;const plane:TzeVector4d;
  out t :double):Boolean;overload;inline;
function PlaneFrom3Pont(const P1,P2,P3:TzePoint3d):TzeVector4d;inline;
procedure NormalizePlane(var plane:TzeVector4d);inline;

function CalcTrueInFrustum (const lbegin,lend:TzePoint3d; const frustum:TzeFrustum):TInBoundingVolume;overload;inline;
function CalcTrueInFrustum (const lbegin,lend:TzePoint3s; const frustum:TzeFrustum):TInBoundingVolume;overload;
function CalcPointTrueInFrustum (const lbegin:TzePoint3d; const frustum:TzeFrustum):TInBoundingVolume; inline;
function CalcOutBound4VInFrustum (const OutBound:OutBound4V; const frustum:TzeFrustum):TInBoundingVolume;inline;
function CalcAABBInFrustum (const AABB:TBoundingBox; const frustum:TzeFrustum):TInBoundingVolume;inline;

function GetXfFromZ(const oz:TzeVector3d):TzeVector3d;inline;

function MatrixDeterminant(const M: TzeTypedMatrix4d):Double;
function CreateMatrixFromBasis(const ox,oy,oz:TzeVector3d):TzeTypedMatrix4d; inline;
procedure CreateBasisFromMatrix(const m:TzeTypedMatrix4d;out ox,oy,oz:TzeVector3d); inline;

function QuaternionFromMatrix(const mat : TzeTypedMatrix4d) : TzeQuaternion;
function QuaternionSlerp(const source, dest: TzeQuaternion; const t: Double): TzeQuaternion;
function QuaternionToMatrix(quat : TzeQuaternion) :  TzeTypedMatrix4d;

function GetArcParamFrom3Point2D(const PointData:tarcrtmodify;out ad:TArcData):Boolean;

function isNotReadableAngle(Angle:Double):Boolean; inline;
function CorrectAngleIfNotReadable(Angle:Double):Double; inline;

function GetCSDirFrom0x0y2D(const ox,oy:TzeVector3d):TCSDir;

function CalcDisplaySubFrustum(const x,y,w,h:Double;const mm,pm:TzeTypedMatrix4d;const vp:TzeVector4i):TzeFrustum;
function myPickMatrix(const x,y,deltax,deltay:Double;const vp:TzeVector4i): TzeTypedMatrix4d;

function GetPointInOCSByBasis(const ScaledBX,ScaledBY,ScaledBZ:TzeVector3d;const PointInWCS:TzePoint3d;
  out scale:TzeVector3d):GDBObj2dprop;
function GetPInsertInOCSBymatrix(constref matrix:TzeTypedMatrix4d;out scale:TzeVector3d):GDBObj2dprop;

function PreCalcBulgeToArcSegment(constref p1,p2:TzePoint2d;const bulge:double;const divcount:integer):integer;overload;
function PreCalcBulgeToArcSegment(constref p1,p2:TzePoint2d;const bulge:double;const divcount:integer;
  var ActualDivCount:Integer):integer;overload;
procedure CalcBulgeToArcSegment(constref p1,p2:TzePoint2d;const bulge:double;var pts:array of TzePoint2d;
  divcount:integer);

function intercept2dmy(const l1begin,l1end,l2begin,l2end:TzePoint2d):intercept2dprop;//inline;
function intercept3dmy(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;//inline;
function intercept3dmy2(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;//inline;
//** Функция позволяет найти пересечение по 2-м координатам одной линии и другой
function intercept3d(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;//inline;


operator -(const l:TzePoint2d;r:TzePoint2i):TzePoint2d;inline;overload;

type
  TLineClipArray=array[0..5]of Double;

implementation

operator -(const l:TzePoint2d;r:TzePoint2i):TzePoint2d;
begin
  result.x:=l.x-r.x;
  result.y:=l.y-r.y;
end;

function PreCalcBulgeToArcSegment(constref p1,p2:TzePoint2d;const bulge:double;const divcount:integer):integer;overload;
begin
  if divcount<1 then
    result:=(1 shl (min(max(2,abs(round(bulge*2))),5)))+1
  else
    result:=(1 shl (divcount))+1;
end;

function PreCalcBulgeToArcSegment(constref p1,p2:TzePoint2d;const bulge:double;const divcount:integer;var ActualDivCount:Integer):integer;overload;
begin
  if divcount<1 then
    ActualDivCount:=min(max(2,abs(round(bulge*2))),5)
  else
    ActualDivCount:=divcount;
  result:=(1 shl ActualDivCount)+1;
end;

procedure CalcBulgeToArcSegment(constref p1,p2:TzePoint2d;const bulge:double;var pts:array of TzePoint2d;divcount:integer);
var
  d,n:TzeVector2d;
  pc,pac:TzePoint2d;
  l,h,nextbulge:double;
  mid:integer;
begin
  d:=p2-p1;
  l:=d.Length;
  h:=l*bulge/2;
  pc:=(p1+p2.asVector)/2;
  n:=d.Turned90L;
  n.Normalize;
  pac:=pc-n*h;
  if divcount=1 then begin
    pts[low(pts)]:=p1;
    pts[low(pts)+1]:=pac;
  end else begin
    Dec(divcount);
    nextbulge:=bulge/(1+sqrt(1+bulge*bulge));
    mid:=length(pts) div 2;
    CalcBulgeToArcSegment(p1,pac,nextbulge,pts[0..mid-1],divcount);
    CalcBulgeToArcSegment(pac,p2,nextbulge,pts[mid..high(pts)],divcount);
  end;
end;

function GetPInsertInOCSBymatrix(constref matrix:TzeTypedMatrix4d;out scale:TzeVector3d):GDBObj2dprop;
var
  BX,BY,BZ:TzeVector3d;
  pt:TzePoint3d;
begin
  BX:=matrix.mtr.v[0].Slice;
  BY:=matrix.mtr.v[1].Slice;
  BZ:=matrix.mtr.v[2].Slice;
  pt:=matrix.mtr.v[3].Slice.asPoint3d;
  result:=GetPointInOCSByBasis(BX,BY,BZ,pt,scale);
end;

function isNotReadableAngle(Angle:Double):Boolean;
begin
  if (Angle>(pi*0.5+eps))and(Angle<(pi*1.5+eps)) then
    Result:=true
  else
    Result:=false;
end;
function CorrectAngleIfNotReadable(Angle:Double):Double;
begin
  if isNotReadableAngle(Angle) then
    Result:=angle-pi
  else
    Result:=angle;
end;

function IsNearToZ(const v:TzeVector3d):boolean;
const
  tol=1/64;
begin
  result:=(abs(v.x)<tol)and(abs(v.y)<tol);
end;

function IsValidRange(const d1,d2:Double):boolean;
begin
  if abs(d2)<eps then begin
    result:=abs(d1.Exponent)<45;
  end else begin
    if abs(d1)<eps then
      result:=abs(d2.Exponent)<45
    else
      result:=abs(d2.Exponent-d1.Exponent)<45;
  end;
end;

function GetMinAndSwap(var position:integer;size:integer;var ca:TLineClipArray):Double;
var
  i,hpos:integer;
  d1:double;
begin
  Result:=ca[position];
  hpos:=-1;
  for I:=position to size do begin
    if ca[i]<=Result then begin
      Result:=ca[i];
      hpos:=i;
    end;
  end;
  if hpos<>-1 then begin
    d1:=ca[hpos];
    ca[hpos]:=ca[position];
    ca[position]:=d1;
  end;
  Result:=ca[position];
  Inc(position);
end;

function CalcOutBound4VInFrustum (const OutBound:OutBound4V; const frustum:TzeFrustum):TInBoundingVolume;
var
  i,Count:integer;
  d1,d2,d3,d4:double;
begin
  Count:=0;
  for i:=0 to 5 do begin
    with frustum.v[i] do begin
      d1:=v[0]*outbound[0].x+v[1]*outbound[0].y+v[2]*outbound[0].z+v[3];
      d2:=v[0]*outbound[1].x+v[1]*outbound[1].y+v[2]*outbound[1].z+v[3];
      d3:=v[0]*outbound[2].x+v[1]*outbound[2].y+v[2]*outbound[2].z+v[3];
      d4:=v[0]*outbound[3].x+v[1]*outbound[3].y+v[2]*outbound[3].z+v[3];
    end;
    if (d1<0)and(d2<0)and(d3<0)and(d4<0) then begin
      Result:=irempty;
      system.exit;
    end;
    if d1>=0 then
      Inc(Count);
    if d2>=0 then
      Inc(Count);
    if d3>=0 then
      Inc(Count);
    if d4>=0 then
      Inc(Count);
  end;
  if Count=24 then begin
    Result:=irfully;
    exit;
  end;

  Result:=IRPartially;
end;
function CalcPointTrueInFrustum(const lbegin:TzePoint3d;const frustum:TzeFrustum):TInBoundingVolume;
var
  i:integer;
begin
  for i:=0 to 5 do begin
    with frustum.v[i] do
      if (v[0]*lbegin.x+v[1]*lbegin.y+v[2]*lbegin.z+v[3])<0 then
        exit(IREmpty);
  end;
  Result:=IRFully;
end;

procedure NormalizePlane(var plane:TzeVector4d);{inline;}
var
  t:double;
begin
  with TzeVector4d((@plane)^) do begin
    t:=sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
    v[0]:=v[0]/t;
    v[1]:=v[1]/t;
    v[2]:=v[2]/t;
    v[3]:=v[3]/t;
  end;
end;

function PlaneFrom3Pont(const P1,P2,P3:TzePoint3d):TzeVector4d;
begin
  with TzePoint3d((@P1)^) do begin
    result.v[0]:=   y*(P2.z - P3.z)           + P2.y*(P3.z - z)        + P3.y*(z - P2.z);
    result.v[1]:=   z*(P2.x - P3.x)           + P2.z*(P3.x - x)        + P3.z*(x - P2.x);
    result.v[2]:=   x*(P2.y - P3.y)           + P2.x*(P3.y - y)        + P3.x*(y - P2.y);
    result.v[3]:= -(x*(P2.y*P3.z - P3.y*P2.z) + P2.x*(P3.y*z - y*P3.z) + P3.x*(y*P2.z - P2.y*z));
  end;
end;


function calcfrustum(const clip:PzeTypedMatrix4d):TzeFrustum;
var
  t:double;
begin
  //* Находим A, B, C, D для ПРАВОЙ плоскости */
  with TzeVector4d((@result.v[0])^) do begin
    v[0]:=clip^.mtr.v[0].v[3]-clip^.mtr.v[0].v[0];
    v[1]:=clip^.mtr.v[1].v[3]-clip^.mtr.v[1].v[0];
    v[2]:=clip^.mtr.v[2].v[3]-clip^.mtr.v[2].v[0];
    v[3]:=clip^.mtr.v[3].v[3]-clip^.mtr.v[3].v[0];
    t:=sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
    v[0]:=v[0]/t;
    v[1]:=v[1]/t;
    v[2]:=v[2]/t;
    v[3]:=v[3]/t;
  end;

  //* Находим A, B, C, D для ЛЕВОЙ плоскости */
  with TzeVector4d((@result.v[1])^) do begin
    v[0]:=clip^.mtr.v[0].v[3]+clip^.mtr.v[0].v[0];
    v[1]:=clip^.mtr.v[1].v[3]+clip^.mtr.v[1].v[0];
    v[2]:=clip^.mtr.v[2].v[3]+clip^.mtr.v[2].v[0];
    v[3]:=clip^.mtr.v[3].v[3]+clip^.mtr.v[3].v[0];
    t:=sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
    v[0]:=v[0]/t;
    v[1]:=v[1]/t;
    v[2]:=v[2]/t;
    v[3]:=v[3]/t;
  end;

  //* Находим A, B, C, D для НИЖНЕЙ плоскости */
  with TzeVector4d((@result.v[2])^) do begin
    v[0]:=clip^.mtr.v[0].v[3]+clip^.mtr.v[0].v[1];
    v[1]:=clip^.mtr.v[1].v[3]+clip^.mtr.v[1].v[1];
    v[2]:=clip^.mtr.v[2].v[3]+clip^.mtr.v[2].v[1];
    v[3]:=clip^.mtr.v[3].v[3]+clip^.mtr.v[3].v[1];
    t:=sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
    v[0]:=v[0]/t;
    v[1]:=v[1]/t;
    v[2]:=v[2]/t;
    v[3]:=v[3]/t;
  end;

  //* ВЕРХНЯЯ плоскость */
  with TzeVector4d((@result.v[3])^) do begin
    v[0]:=clip^.mtr.v[0].v[3]-clip^.mtr.v[0].v[1];
    v[1]:=clip^.mtr.v[1].v[3]-clip^.mtr.v[1].v[1];
    v[2]:=clip^.mtr.v[2].v[3]-clip^.mtr.v[2].v[1];
    v[3]:=clip^.mtr.v[3].v[3]-clip^.mtr.v[3].v[1];
    t:=sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
    v[0]:=v[0]/t;
    v[1]:=v[1]/t;
    v[2]:=v[2]/t;
    v[3]:=v[3]/t;
  end;

  //* ПЕРЕДНЯЯ плоскость */
  with TzeVector4d((@result.v[4])^) do begin
    v[0]:=clip^.mtr.v[0].v[3]+clip^.mtr.v[0].v[2];
    v[1]:=clip^.mtr.v[1].v[3]+clip^.mtr.v[1].v[2];
    v[2]:=clip^.mtr.v[2].v[3]+clip^.mtr.v[2].v[2];
    v[3]:=clip^.mtr.v[3].v[3]+clip^.mtr.v[3].v[2];
    t:=sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
    v[0]:=v[0]/t;
    v[1]:=v[1]/t;
    v[2]:=v[2]/t;
    v[3]:=v[3]/t;
  end;

   //* ЗАДНЯЯ?? плоскость */
  with TzeVector4d((@result.v[5])^) do begin
    v[0]:=clip^.mtr.v[0].v[3]-clip^.mtr.v[0].v[2];
    v[1]:=clip^.mtr.v[1].v[3]-clip^.mtr.v[1].v[2];
    v[2]:=clip^.mtr.v[2].v[3]-clip^.mtr.v[2].v[2];
    v[3]:=clip^.mtr.v[3].v[3]-clip^.mtr.v[3].v[2];
    t:=sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
    v[0]:=v[0]/t;
    v[1]:=v[1]/t;
    v[2]:=v[2]/t;
    v[3]:=v[3]/t;
  end;
end;

function MatrixDetInternal(const a1,a2,a3,b1,b2,b3,c1,c2,c3:double):double;inline;
begin
  Result:=+a1*(b2*c3-b3*c2)
          -b1*(a2*c3-a3*c2)
          +c1*(a2*b3-a3*b2);
end;
procedure MatrixAdjoint(var M:TzeTypedMatrix4d);
var
  a1,a2,a3,a4,
  b1,b2,b3,b4,
  c1,c2,c3,c4,
  d1,d2,d3,d4:Double;
begin
  with TzeVector4d((@M.mtr.v[0])^) do begin
    a1:=v[0];
    b1:=v[1];
    c1:=v[2];
    d1:=v[3];
  end;
  with TzeVector4d((@M.mtr.v[1])^) do begin
    a2:=v[0];
    b2:=v[1];
    c2:=v[2];
    d2:=v[3];
  end;
  with TzeVector4d((@M.mtr.v[2])^) do begin
    a3:=v[0];
    b3:=v[1];
    c3:=v[2];
    d3:=v[3];
  end;
  with TzeVector4d((@M.mtr.v[3])^) do begin
    a4:=v[0];
    b4:=v[1];
    c4:=v[2];
    d4:=v[3];
  end;
    //a1:=M[0].v[0];b1:=M[0].v[1];
    //c1:=M[0].v[2];d1:=M[0].v[3];
    //a2:=M[1].v[0];b2:=M[1].v[1];
    //c2:=M[1].v[2];d2:=M[1].v[3];
    //a3:=M[2].v[0];b3:=M[2].v[1];
    //c3:=M[2].v[2];d3:=M[2].v[3];
    //a4:=M[3].v[0];b4:=M[3].v[1];
    //c4:=M[3].v[2];d4:=M[3].v[3];

    // row column labeling reversed since we transpose rows & columns
    M.mtr.v[cxAxisIndex].v[cxAxisIndex]:= MatrixDetInternal(b2,b3,b4,c2,c3,c4,d2,d3,d4);
    M.mtr.v[cxAxisIndex].v[cyAxisIndex]:=-MatrixDetInternal(b1,b3,b4,c1,c3,c4,d1,d3,d4);
    M.mtr.v[cxAxisIndex].v[czAxisIndex]:= MatrixDetInternal(b1,b2,b4,c1,c2,c4,d1,d2,d4);
    M.mtr.v[cxAxisIndex].v[cwAxisIndex]:=-MatrixDetInternal(b1,b2,b3,c1,c2,c3,d1,d2,d3);

    M.mtr.v[cyAxisIndex].v[cxAxisIndex]:=-MatrixDetInternal(a2,a3,a4,c2,c3,c4,d2,d3,d4);
    M.mtr.v[cyAxisIndex].v[cyAxisIndex]:= MatrixDetInternal(a1,a3,a4,c1,c3,c4,d1,d3,d4);
    M.mtr.v[cyAxisIndex].v[czAxisIndex]:=-MatrixDetInternal(a1,a2,a4,c1,c2,c4,d1,d2,d4);
    M.mtr.v[cyAxisIndex].v[cwAxisIndex]:= MatrixDetInternal(a1,a2,a3,c1,c2,c3,d1,d2,d3);

    M.mtr.v[czAxisIndex].v[cxAxisIndex]:= MatrixDetInternal(a2,a3,a4,b2,b3,b4,d2,d3,d4);
    M.mtr.v[czAxisIndex].v[cyAxisIndex]:=-MatrixDetInternal(a1,a3,a4,b1,b3,b4,d1,d3,d4);
    M.mtr.v[czAxisIndex].v[czAxisIndex]:= MatrixDetInternal(a1,a2,a4,b1,b2,b4,d1,d2,d4);
    M.mtr.v[czAxisIndex].v[cwAxisIndex]:=-MatrixDetInternal(a1,a2,a3,b1,b2,b3,d1,d2,d3);

    M.mtr.v[cwAxisIndex].v[cxAxisIndex]:=-MatrixDetInternal(a2,a3,a4,b2,b3,b4,c2,c3,c4);
    M.mtr.v[cwAxisIndex].v[cyAxisIndex]:= MatrixDetInternal(a1,a3,a4,b1,b3,b4,c1,c3,c4);
    M.mtr.v[cwAxisIndex].v[czAxisIndex]:=-MatrixDetInternal(a1,a2,a4,b1,b2,b4,c1,c2,c4);
    M.mtr.v[cwAxisIndex].v[cwAxisIndex]:= MatrixDetInternal(a1,a2,a3,b1,b2,b3,c1,c2,c3);
end;
function MatrixDeterminant(const M: TzeTypedMatrix4d): Double;
var
  a1,a2,a3,a4,
  b1,b2,b3,b4,
  c1,c2,c3,c4,
  d1,d2,d3,d4:Double;
begin
  with TzeVector4d((@M.mtr.v[0])^) do begin
    a1:=v[0];
    b1:=v[1];
    c1:=v[2];
    d1:=v[3];
  end;
  with TzeVector4d((@M.mtr.v[1])^) do begin
    a2:=v[0];
    b2:=v[1];
    c2:=v[2];
    d2:=v[3];
  end;
  with TzeVector4d((@M.mtr.v[2])^) do begin
    a3:=v[0];
    b3:=v[1];
    c3:=v[2];
    d3:=v[3];
  end;
  with TzeVector4d((@M.mtr.v[3])^) do begin
    a4:=v[0];
    b4:=v[1];
    c4:=v[2];
    d4:=v[3];
  end;
  //a1 := M[0].v[0];  b1 := M[0].v[1];  c1 := M[0].v[2];  d1 := M[0].v[3];
  //a2 := M[1].v[0];  b2 := M[1].v[1];  c2 := M[1].v[2];  d2 := M[1].v[3];
  //a3 := M[2].v[0];  b3 := M[2].v[1];  c3 := M[2].v[2];  d3 := M[2].v[3];
  //a4 := M[3].v[0];  b4 := M[3].v[1];  c4 := M[3].v[3];  d4 := M[3].v[3];

  Result:= a1*MatrixDetInternal(b2,b3,b4,c2,c3,c4,d2,d3,d4)
          -b1*MatrixDetInternal(a2,a3,a4,c2,c3,c4,d2,d3,d4)
          +c1*MatrixDetInternal(a2,a3,a4,b2,b3,b4,d2,d3,d4)
          -d1*MatrixDetInternal(a2,a3,a4,b2,b3,b4,c2,c3,c4);
end;

procedure MatrixScale(var M: TzeTypedMatrix4d; const Factor: Double);
begin
  with TzeVector4d((@M.mtr.v[0])^) do begin
    v[0]:=v[0]*Factor;
    v[1]:=v[1]*Factor;
    v[2]:=v[2]*Factor;
    v[3]:=v[3]*Factor;
  end;
  with TzeVector4d((@M.mtr.v[1])^) do begin
    v[0]:=v[0]*Factor;
    v[1]:=v[1]*Factor;
    v[2]:=v[2]*Factor;
    v[3]:=v[3]*Factor;
  end;
  with TzeVector4d((@M.mtr.v[2])^) do begin
    v[0]:=v[0]*Factor;
    v[1]:=v[1]*Factor;
    v[2]:=v[2]*Factor;
    v[3]:=v[3]*Factor;
  end;
  with TzeVector4d((@M.mtr.v[3])^) do begin
    v[0]:=v[0]*Factor;
    v[1]:=v[1]*Factor;
    v[2]:=v[2]*Factor;
    v[3]:=v[3]*Factor;
  end;
  //for I := 0 to 3 do
  //  for J := 0 to 3 do M[I].v[J] := M[I].v[J] * Factor;
end;

procedure MatrixInvert(var M: TzeTypedMatrix4d);
var
  Det:double;
begin
  Det:=MatrixDeterminant(M);
  if IsZero(Det) then
    M:=cOneMatrix
  else begin
    MatrixAdjoint(M);
    MatrixScale(M,1/Det);
  end;
end;

function distance2piece(const q,p1,p2:TzePoint3d):double;
var
  t,w,p2x_p1x,p2y_p1y,qx_p1x,qy_p1y,qy_p2y,qx_p2x:double;
begin
  p2x_p1x:=p2.x-p1.x;
  p2y_p1y:=p2.y-p1.y;
  qx_p1x:=q.x-p1.x;
  qx_p2x:=q.x-p2.x;
  qy_p1y:=q.y-p1.y;
  qy_p2y:=q.y-p2.y;
  if((qx_p1x)*(p2x_p1x)+(qy_p1y)*(p2y_p1y))*((qx_p2x)*(p2x_p1x)+(qy_p2y)*(p2y_p1y))>-eps then begin
    t:=sqr(qx_p1x)+sqr(qy_p1y);
    w:=sqr(qx_p2x)+sqr(qy_p2y);
    if w<t then
      t:=w;
  end else begin
    t:=sqr((qx_p1x)*(p2y_p1y)-(qy_p1y)*(p2x_p1x))/(sqr(p2x_p1x)+sqr(p2y_p1y));
  end;
  Result:=sqrt(t);
end;

function distance2piece_2dmy(const q,p1,p2:TzePoint2d):double;
var
  t,w,p2x_p1x,p2y_p1y,qx_p1x,qy_p1y,qy_p2y,qx_p2x:double;
begin
  p2x_p1x:=p2.x-p1.x;
  p2y_p1y:=p2.y-p1.y;
  qx_p1x:=q.x-p1.x;
  qx_p2x:=q.x-p2.x;
  qy_p1y:=q.y-p1.y;
  qy_p2y:=q.y-p2.y;
  if ((qx_p1x)*(p2x_p1x)+(qy_p1y)*(p2y_p1y))*((qx_p2x)*(p2x_p1x)+(qy_p2y)*(p2y_p1y))>-eps then begin
    t:=sqr(qx_p1x)+sqr(qy_p1y);
    w:=sqr(qx_p2x)+sqr(qy_p2y);
    if w<t then
      t:=w;
  end else
    t:=sqr((qx_p1x)*(p2y_p1y)-(qy_p1y)*(p2x_p1x))/(sqr(p2x_p1x)+sqr(p2y_p1y));
  Result:=t;
end;

function CreateTranslationMatrix(const _V:TzeVector3d):TzeTypedMatrix4d;
begin
  Result.CreateRec(cOneMtr,CMTTranslate);
  with TzeVector4d((@Result.mtr.v[3])^) do begin
    v[0]:=_V.x;
    v[1]:=_V.y;
    v[2]:=_V.z;
    v[3]:=1;
  end;
end;

function CreateTranslationMatrix(const tx,ty,tz:double):TzeTypedMatrix4d;
begin
  Result.CreateRec(cOneMtr,CMTTranslate);
  with TzeVector4d((@Result.mtr.v[3])^) do begin
    v[0]:=tx;
    v[1]:=ty;
    v[2]:=tz;
    v[3]:=1;
  end;
end;

function CreateReflectionMatrix(const plane:TzeVector4d): TzeTypedMatrix4d;
var
  d:double;
begin
  with TzeVector4d((@plane)^) do begin
    d:=v[0];
    Result.mtr.v[0].v[0]:=-2*d*v[0]+1;
    Result.mtr.v[1].v[0]:=-2*d*v[1];
    Result.mtr.v[2].v[0]:=-2*d*v[2];
    Result.mtr.v[3].v[0]:=-2*d*v[3];

    d:=v[1];
    Result.mtr.v[0].v[1]:=-2*d*v[0];
    Result.mtr.v[1].v[1]:=-2*d*v[1]+1;
    Result.mtr.v[2].v[1]:=-2*d*v[2];
    Result.mtr.v[3].v[1]:=-2*d*v[3];

    d:=v[2];
    Result.mtr.v[0].v[2]:=-2*d*v[0];
    Result.mtr.v[1].v[2]:=-2*d*v[1];
    Result.mtr.v[2].v[2]:=-2*d*v[2]+1;
    Result.mtr.v[3].v[2]:=-2*d*v[3];
  end;
  Result.mtr.v[0].v[3]:=0;
  Result.mtr.v[1].v[3]:=0;
  Result.mtr.v[2].v[3]:=0;
  Result.mtr.v[3].v[3]:=1;
  Result.t:=CMTTransform;
end;

function CreateScaleMatrix(const V:TzeVector3d): TzeTypedMatrix4d;
begin
  Result.mtr.v:=cOneMtr.v;
  Result.mtr.v[0].v[0]:=V.x;
  Result.mtr.v[1].v[1]:=V.y;
  Result.mtr.v[2].v[2]:=V.z;
  Result.mtr.v[3].v[3]:=1;
  Result.t:=CMTScale;
end;

function CreateScaleMatrix(const s:Double): TzeTypedMatrix4d;
begin
  Result.mtr.v:=cOneMtr.v;
  Result.mtr.v[0].v[0]:=S;
  Result.mtr.v[1].v[1]:=S;
  Result.mtr.v[2].v[2]:=S;
  Result.mtr.v[3].v[3]:=1;
  Result.t:=CMTScale;
end;

function CreateScaleMatrix(const sx,sy,sz:Double): TzeTypedMatrix4d;inline;overload;
begin
  Result.mtr.v:=cOneMtr.v;
  Result.mtr.v[0].v[0]:=sx;
  Result.mtr.v[1].v[1]:=sy;
  Result.mtr.v[2].v[2]:=sz;
  Result.mtr.v[3].v[3]:=1;
  Result.t:=CMTScale;
end;

function CreateRotationMatrixX(const angle:double):TzeTypedMatrix4d;
var
  Sine,Cosine:double;
begin
  SinCos(angle,Sine,Cosine);
  Result:=cEmptyMatrix;
  Result.mtr.v[0].v[0]:=1;
  Result.mtr.v[1].v[1]:=Cosine;
  Result.mtr.v[1].v[2]:=Sine;
  Result.mtr.v[2].v[1]:=-Sine;
  Result.mtr.v[2].v[2]:=Cosine;
  Result.mtr.v[3].v[3]:=1;
  Result.t:=CMTRotate;
end;

function CreateRotationMatrixY(const angle:double):TzeTypedMatrix4d;
var
  Sine,Cosine:double;
begin
  SinCos(angle,Sine,Cosine);
  Result:=cEmptyMatrix;
  Result.mtr.v[0].v[0]:=Cosine;
  Result.mtr.v[0].v[2]:=-Sine;
  Result.mtr.v[1].v[1]:=1;
  Result.mtr.v[2].v[0]:=Sine;
  Result.mtr.v[2].v[2]:=Cosine;
  Result.mtr.v[3].v[3]:=1;
  Result.t:=CMTRotate;
end;

function CreateRotatedXVector(const angle:double):TzeVector3d;
begin
  SinCos(angle,Result.y,Result.x);
  Result.z:=0;
end;

function CreateRotatedYVector(const angle:double):TzeVector3d;
begin
  Result:=CreateRotatedXVector(angle+pi/2);
end;

function CreateRotationMatrixZ(const angle:double):TzeTypedMatrix4d;
var
  Sine,Cosine:double;
begin
  SinCos(angle,Sine,Cosine);
  Result:=cOneMatrix;
  Result.mtr.v[0].v[0]:=Cosine;
  Result.mtr.v[0].v[1]:=Sine;
  Result.mtr.v[1].v[1]:=Cosine;
  Result.mtr.v[1].v[0]:=-Sine;
  Result.t:=CMTRotate;
end;

function MatrixMultiply(const M1,M2:TzeTypedMatrix4d):TzeTypedMatrix4d;
var
  I:integer;
begin
  for I:=3 downto 0 do begin
    with M1.mtr.v[I] do begin
      Result.mtr.v[I].v[0]:=v[0]*M2.mtr.v[0].v[0]+v[1]*M2.mtr.v[1].v[0]+v[2]*M2.mtr.v[2].v[0]+v[3]*M2.mtr.v[3].v[0];
      Result.mtr.v[I].v[1]:=v[0]*M2.mtr.v[0].v[1]+v[1]*M2.mtr.v[1].v[1]+v[2]*M2.mtr.v[2].v[1]+v[3]*M2.mtr.v[3].v[1];
      Result.mtr.v[I].v[2]:=v[0]*M2.mtr.v[0].v[2]+v[1]*M2.mtr.v[1].v[2]+v[2]*M2.mtr.v[2].v[2]+v[3]*M2.mtr.v[3].v[2];
      Result.mtr.v[I].v[3]:=v[0]*M2.mtr.v[0].v[3]+v[1]*M2.mtr.v[1].v[3]+v[2]*M2.mtr.v[2].v[3]+v[3]*M2.mtr.v[3].v[3];
    end;
  end;
  Result.t:=M1.t+M2.t;
end;

function MatrixMultiply(const M1:TzeTypedMatrix4d;const M2:TzeTypedMatrix4s):TzeTypedMatrix4d;
var
  I:integer;
begin
  for I:=3 downto 0 do begin
    with M1.mtr.v[I] do begin
      Result.mtr.v[I].v[0]:=v[0]*M2.mtr.v[0].v[0]+v[1]*M2.mtr.v[1].v[0]+v[2]*M2.mtr.v[2].v[0]+v[3]*M2.mtr.v[3].v[0];
      Result.mtr.v[I].v[1]:=v[0]*M2.mtr.v[0].v[1]+v[1]*M2.mtr.v[1].v[1]+v[2]*M2.mtr.v[2].v[1]+v[3]*M2.mtr.v[3].v[1];
      Result.mtr.v[I].v[2]:=v[0]*M2.mtr.v[0].v[2]+v[1]*M2.mtr.v[1].v[2]+v[2]*M2.mtr.v[2].v[2]+v[3]*M2.mtr.v[3].v[2];
      Result.mtr.v[I].v[3]:=v[0]*M2.mtr.v[0].v[3]+v[1]*M2.mtr.v[1].v[3]+v[2]*M2.mtr.v[2].v[3]+v[3]*M2.mtr.v[3].v[3];
    end;
  end;
  Result.t:=M1.t+M2.t;
end;

function MatrixMultiplyF(const M1,M2:TzeTypedMatrix4d):TzeTypedMatrix4s;
var
  I:integer;
begin
  for I:=3 downto 0 do begin
    with M1.mtr.v[I] do begin
      Result.mtr.v[I].v[0]:=v[0]*M2.mtr.v[0].v[0]+v[1]*M2.mtr.v[1].v[0]+v[2]*M2.mtr.v[2].v[0]+v[3]*M2.mtr.v[3].v[0];
      Result.mtr.v[I].v[1]:=v[0]*M2.mtr.v[0].v[1]+v[1]*M2.mtr.v[1].v[1]+v[2]*M2.mtr.v[2].v[1]+v[3]*M2.mtr.v[3].v[1];
      Result.mtr.v[I].v[2]:=v[0]*M2.mtr.v[0].v[2]+v[1]*M2.mtr.v[1].v[2]+v[2]*M2.mtr.v[2].v[2]+v[3]*M2.mtr.v[3].v[2];
      Result.mtr.v[I].v[3]:=v[0]*M2.mtr.v[0].v[3]+v[1]*M2.mtr.v[1].v[3]+v[2]*M2.mtr.v[2].v[3]+v[3]*M2.mtr.v[3].v[3];
    end;
  end;
  Result.t:=M1.t+M2.t;
end;

procedure MatrixTranspose(var M:TzeTypedMatrix4d);
var
  I:integer;
  TM:TzeTypedMatrix4d;
begin
  for I:=3 downto 0 do begin
    with M.mtr.v[I] do begin
      TM.mtr.v[0].v[I]:=v[0];
      TM.mtr.v[1].v[I]:=v[1];
      TM.mtr.v[2].v[I]:=v[2];
      TM.mtr.v[3].v[I]:=v[3];
    end;
  end;
  M.mtr:=TM.mtr;
end;

procedure MatrixTranspose(var M:TzeTypedMatrix4s);
var
  I:integer;
  TM:TzeTypedMatrix4s;
begin
  for I:=3 downto 0 do begin
    with M.mtr.v[I] do begin
      TM.mtr.v[0].v[I]:=v[0];
      TM.mtr.v[1].v[I]:=v[1];
      TM.mtr.v[2].v[I]:=v[2];
      TM.mtr.v[3].v[I]:=v[3];
    end;
  end;
  M.mtr:=TM.mtr;
end;

procedure MatrixNormalize(var M:TzeTypedMatrix4d);
var
  I:integer;
  D:double;
begin
  D:=M.mtr.v[3].v[3];
  for I:=3 downto 0 do begin
    with M.mtr.v[I] do begin
      v[0]:=v[0]/D;
      v[1]:=v[1]/D;
      v[2]:=v[2]/D;
      v[3]:=v[3]/D;
    end;
  end;
end;

function VectorTransform(const V:TzeVector4d;const M:TzeTypedMatrix4d):TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else
    with TzeVector4d((@V)^) do begin
      Result.X:=X*M.mtr.v[0].v[0]+y*M.mtr.v[1].v[0]+z*M.mtr.v[2].v[0]+w*M.mtr.v[3].v[0];
      Result.Y:=X*M.mtr.v[0].v[1]+y*M.mtr.v[1].v[1]+z*M.mtr.v[2].v[1]+w*M.mtr.v[3].v[1];
      Result.z:=x*M.mtr.v[0].v[2]+y*M.mtr.v[1].v[2]+z*M.mtr.v[2].v[2]+w*M.mtr.v[3].v[2];
      Result.W:=x*M.mtr.v[0].v[3]+y*M.mtr.v[1].v[3]+z*M.mtr.v[2].v[3]+w*M.mtr.v[3].v[3];
    end;
end;

function VectorTransform(const V:TzeVector4d;const M:TzeTypedMatrix4s):TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else
    with TzeVector4d((@V)^) do begin
      Result.X:=X*M.mtr.v[0].v[0]+y*M.mtr.v[1].v[0]+z*M.mtr.v[2].v[0]+w*M.mtr.v[3].v[0];
      Result.Y:=X*M.mtr.v[0].v[1]+y*M.mtr.v[1].v[1]+z*M.mtr.v[2].v[1]+w*M.mtr.v[3].v[1];
      Result.z:=x*M.mtr.v[0].v[2]+y*M.mtr.v[1].v[2]+z*M.mtr.v[2].v[2]+w*M.mtr.v[3].v[2];
      Result.W:=x*M.mtr.v[0].v[3]+y*M.mtr.v[1].v[3]+z*M.mtr.v[2].v[3]+w*M.mtr.v[3].v[3];
    end;
end;

function VectorTransform(const V:TzeVector4s;const M:TzeTypedMatrix4s):TzeVector4s;
begin
  if M.t=CMTIdentity then
    Result:=V
  else
    with TzeVector4s((@V)^) do begin
      Result.X:=X*M.mtr.v[0].v[0]+y*M.mtr.v[1].v[0]+z*M.mtr.v[2].v[0]+w*M.mtr.v[3].v[0];
      Result.Y:=X*M.mtr.v[0].v[1]+y*M.mtr.v[1].v[1]+z*M.mtr.v[2].v[1]+w*M.mtr.v[3].v[1];
      Result.z:=x*M.mtr.v[0].v[2]+y*M.mtr.v[1].v[2]+z*M.mtr.v[2].v[2]+w*M.mtr.v[3].v[2];
      Result.W:=x*M.mtr.v[0].v[3]+y*M.mtr.v[1].v[3]+z*M.mtr.v[2].v[3]+w*M.mtr.v[3].v[3];
    end;
end;

function VectorTransform2D(const V:TzePoint2d;const M:TzeTypedMatrix4d):TzePoint3d;
var
  TV:TzeVector4d;
begin
  if M.t=CMTIdentity then begin
    //Result:=CreateVertex(v.x,v.y,0)
    Result.setup(v,0);
  end
  else begin
    tv.Slice.Slice:=v.asVector;
    tv.z:=0;
    tv.w:=1;
    tv:=VectorTransform(tv,m);
    Result:=tv.DeHomogenized.asPoint3d;
  end;
end;

function VectorTransform3D(const V:TzePoint3d;const M:TzeTypedMatrix4d):TzePoint3d;
var
  TV:TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else begin
    tv.Slice:=v.asVector;
    tv.w:=1;
    tv:=VectorTransform(tv,m);
    Result:=tv.DeHomogenized.asPoint3d;
  end;
end;

function VectorTransform3D(const V:TzeVector3d;const M:TzeTypedMatrix4d):TzeVector3d;overload;
begin
  result:=VectorTransform3D(V.asPoint3d,M).asVector;
end;

function VectorTransform3D(const V:TzePoint3d;const M:TzeTypedMatrix4s):TzePoint3d;
var
  TV:TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else begin
    tv.Slice:=v.asVector;
    tv.w:=1;
    tv:=VectorTransform(tv,m);
    Result:=tv.DeHomogenized.asPoint3d;
  end;
end;

function VectorTransform3D(const V:TzePoint3s;const M:TzeTypedMatrix4d):TzePoint3s;
var
  tv:TzeVector4d;
begin
  if M.t=CMTIdentity then
    Result:=V
  else begin
    tv.x:=v.x;
    tv.y:=v.y;
    tv.z:=v.z;
    tv.w:=1;
    tv:=VectorTransform(tv,m);
    tv.DeHomogenize;
    Result.x:=tv.x;
    Result.y:=tv.y;
    Result.z:=tv.z;
  end;
end;

function VectorTransform3D(const V:TzePoint3s;const M:TzeTypedMatrix4s):TzePoint3s;
var
  tv:TzeVector4s;
begin
  tv.x:=v.x;
  tv.y:=v.y;
  tv.z:=v.z;
  tv.w:=1;
  tv:=VectorTransform(tv,m);
  tv.DeHomogenize;
  Result.x:=tv.x;
  Result.y:=tv.y;
  Result.z:=tv.z;
end;

function FrustumTransform(const frustum:TzeFrustum;const M:TzeTypedMatrix4d;MatrixAlreadyTransposed:boolean=False):TzeFrustum;
var
  m1:TzeTypedMatrix4d;
begin
  if MatrixAlreadyTransposed then begin
    Result.v[0]:=VectorTransform(frustum.v[0],M);
    Result.v[1]:=VectorTransform(frustum.v[1],M);
    Result.v[2]:=VectorTransform(frustum.v[2],M);
    Result.v[3]:=VectorTransform(frustum.v[3],M);
    Result.v[4]:=VectorTransform(frustum.v[4],M);
    Result.v[5]:=VectorTransform(frustum.v[5],M);
  end else begin
    m1:=M;
    MatrixTranspose(m1);
    Result.v[0]:=VectorTransform(frustum.v[0],m1);
    Result.v[1]:=VectorTransform(frustum.v[1],m1);
    Result.v[2]:=VectorTransform(frustum.v[2],m1);
    Result.v[3]:=VectorTransform(frustum.v[3],m1);
    Result.v[4]:=VectorTransform(frustum.v[4],m1);
    Result.v[5]:=VectorTransform(frustum.v[5],m1);
  end;
end;

function FrustumTransform(const frustum:TzeFrustum;const M:TzeTypedMatrix4s;MatrixAlreadyTransposed:boolean=False):TzeFrustum;
var
  m1:TzeTypedMatrix4s;
begin
  if MatrixAlreadyTransposed then begin
    Result.v[0]:=VectorTransform(frustum.v[0],M);
    Result.v[1]:=VectorTransform(frustum.v[1],M);
    Result.v[2]:=VectorTransform(frustum.v[2],M);
    Result.v[3]:=VectorTransform(frustum.v[3],M);
    Result.v[4]:=VectorTransform(frustum.v[4],M);
    Result.v[5]:=VectorTransform(frustum.v[5],M);
  end else begin
    m1:=M;
    MatrixTranspose(m1);
    Result.v[0]:=VectorTransform(frustum.v[0],m1);
    Result.v[1]:=VectorTransform(frustum.v[1],m1);
    Result.v[2]:=VectorTransform(frustum.v[2],m1);
    Result.v[3]:=VectorTransform(frustum.v[3],m1);
    Result.v[4]:=VectorTransform(frustum.v[4],m1);
    Result.v[5]:=VectorTransform(frustum.v[5],m1);
  end;
end;

function VectorAngle(const AVector:TzeVector2d):double;
var
  temp:double;
begin
  if AVector.x<>0 then
    temp:=arctan(abs(AVector.y/AVector.x))
  else
    temp:=pi/2;
  if (AVector.x>=0) and (AVector.y>=0) then
    Result:=temp
  else if (AVector.x<0) and (AVector.y>=0) then
    Result:=pi-temp
  else if (AVector.x<=0) and (AVector.y<=0) then
    Result:=pi+temp
  else if (AVector.x>0) and (AVector.y<0) then
    Result:=2*pi-temp;
end;

function VectorDot(const v1,v2:TzeVector3d):TzeVector3d;
begin
  with TzePoint3d((@v1)^) do begin
    Result.x:=y*v2.z-z*v2.y;
    Result.y:=z*v2.x-x*v2.z;
    Result.z:=x*v2.y-y*v2.x;
  end;
end;

function ScalarDot(const v1,v2:TzeVector3d):double;
begin
  with TzePoint3d((@v1)^) do
    Result:=x*v2.x+y*v2.y+z*v2.z;
end;

function CreateStringFromArray(var counter:integer;const args:array of const):string;
begin
  case args[counter].VType of
    vtString:Result:=args[counter].VString^;
    vtAnsiString:Result:=ansistring(args[counter].VAnsiString);
    else
      zDebugLn('{E}CreateStringFromArray: not String');
  end;{case}
  Inc(counter);
end;

{function CreateVertex2D(const _x,_y:double):TzePoint2d;
begin
  with TzePoint2d((@Result)^) do begin
    x:=_x;
    y:=_y;
  end;
end;}

{function CreateVector2D(const _x,_y:Double):TzeVector2d;inline;
begin
  with TzeVector2d((@Result)^) do begin
    x:=_x;
    y:=_y;
  end;
end;}

(*procedure concatBBandPoint(var fistbb:TBoundingBox;const point:TzePoint3d);
begin
  fistbb.min.ConcatFromMinSide(point);
  fistbb.max.ConcatFromMaxSide(point);
  {with TzePoint3d((@fistbb.min)^) do begin
    if x>point.x then
      x:=point.x;
    if y>point.y then
      y:=point.y;
    if z>point.z then
      z:=point.z;
  end;

  with TzePoint3d((@fistbb.max)^) do begin
    if x<point.x then
      x:=point.x;
    if y<point.y then
      y:=point.y;
    if z<point.z then
      z:=point.z;
  end;}
end;*)

{function CreateBBFrom2Point(const p1,p2:TzePoint3d):TBoundingBox;
begin
  if p1.x<p2.x then begin
    Result.min.x:=p1.x;
    Result.max.x:=p2.x;
  end else begin
    Result.min.x:=p2.x;
    Result.max.x:=p1.x;
  end;
  if p1.y<p2.y then begin
    Result.min.y:=p1.y;
    Result.max.y:=p2.y;
  end else begin
    Result.min.y:=p2.y;
    Result.max.y:=p1.y;
  end;
  if p1.z<p2.z then begin
    Result.min.z:=p1.z;
    Result.max.z:=p2.z;
  end else begin
    Result.min.z:=p2.z;
    Result.max.z:=p1.z;
  end;
end;}

{function CreateBBFromPoint(const p:TzePoint3d):TBoundingBox;
begin
  Result.Fill(p);
  //Result.min:=p;
  //Result.max:=p;
end;}

function GDBvertexEqual(const v1,v2:TzePoint3d):boolean;inline;
begin
  Result:=(v1.x=v2.x) and (v1.y=v2.y) and (v1.z=v2.z);
end;

{function IsBBZero(const bb:TBoundingBox):boolean;inline;
begin
  with TBoundingBox((@bb)^) do
    Result:=GDBvertexEqual(max,min);
end;}

{procedure ConcatBB(var fistbb:TBoundingBox;const secbb:TBoundingBox);
begin
  if fistbb.IsZero then begin
    fistbb:=secbb;
  end else if not secbb.IsZero then begin
    fistbb.Concat(secbb.min);
    fistbb.Concat(secbb.max);
  end;
end;}

{function IsBBNul(const bb:TBoundingBox):boolean;
begin
  with TBoundingBox((@bb)^) do
    Result:=(min-max).IsNul(eps);
end;}

function IsPointInBB(const point,LBN,RTF:TzePoint3d):boolean;
begin
  //with TzePoint3d((@point)^) do
  //  Result:=(LBN.x<=x+eps)and(RTF.x>=x-eps) and  (LBN.y<=y+eps)and(RTF.y>=y-eps) and  (LBN.z<=z+eps)and(RTF.z>=z-eps);
  result:=LBN.LessOrEqual(point) and RTF.GreaterOrEqual(point);
end;

function IsPointInBB(const point:TzePoint3d;const fistbb:TBoundingBox):boolean;
begin
  with TBoundingBox((@fistbb)^) do
    Result:=IsPointInBB(point,pMin,pMax);
end;

function ScaleBB(const bb:TBoundingBox;const k:double):TBoundingBox;
var
  p:TzePoint3d;
  v:TzeVector3d;
begin
  p:=(bb.pMax+bb.pMin.asVector)/2;
  v:=(bb.pMax-p)*k;
  Result.Make(p-v,p+v);
  {Result.pMin:=p-v;
  Result.pMax:=p+v;}
end;

{function boundingintersect(const bb1,bb2:TBoundingBox):boolean;
var
  b1,b2,b1c,b2c:TzePoint3d;
  dist:TzeVector3d;
begin
  //половина диагонали первого бокса
  b1.x:=(bb1.max.x-bb1.min.x)/2;
  b1.y:=(bb1.max.y-bb1.min.y)/2;
  b1.z:=(bb1.max.z-bb1.min.z)/2;
  //половина диагонали второго бокса
  b2.x:=(bb2.max.x-bb2.min.x)/2;
  b2.y:=(bb2.max.y-bb2.min.y)/2;
  b2.z:=(bb2.max.z-bb2.min.z)/2;
  //центры боксов
  b1c:=bb1.min+b1.asVector;
  b2c:=bb2.min+b2.asVector;
  //расстояние между центрами
  dist:=b1c-b2c;
  dist.x:=abs(dist.x);
  dist.y:=abs(dist.y);
  dist.z:=abs(dist.z);
  //пересечение боксов
  Result:=false;
  if (((b1.x+b2.x)-dist.x)>-bigeps)  and(((b1.y+b2.y)-dist.y)>-bigeps)  and(((b1.z+b2.z)-dist.z)>-bigeps) then
    Result:=true;
end;}

function CreateMatrixFromBasis(const ox,oy,oz:TzeVector3d):TzeTypedMatrix4d;
begin
  Result.CreateRec(cOneMtr,CMTRotate);
  Result.mtr.v[0].Slice:=ox;
  Result.mtr.v[1].Slice:=oy;
  Result.mtr.v[2].Slice:=oz;
end;

procedure CreateBasisFromMatrix(const m:TzeTypedMatrix4d;out ox,oy,oz:TzeVector3d);
begin
  ox:=m.mtr.v[0].Slice;
  oy:=m.mtr.v[1].Slice;
  oz:=m.mtr.v[2].Slice;
end;

function QuaternionMagnitude(const q:TzeQuaternion):double;
begin
  Result:=Sqrt(q.ImagPart.SqrLength+Sqr(q.RealPart));
end;

procedure NormalizeQuaternion(var q:TzeQuaternion);
var
  m,f:double;
begin
  m:=QuaternionMagnitude(q);
  if m>EPSILON2 then begin
    f:=1/m;
    q.ImagPart:=q.ImagPart*f;
    q.RealPart:=q.RealPart*f;
  end else
    q:=cIdentityQuaternion;
end;

function QuaternionFromMatrix(const mat:TzeTypedMatrix4d):TzeQuaternion;
  // the matrix must be a rotation matrix!
var
  traceMat,s,invS:double;
begin
  traceMat:=1+mat.mtr.v[0].v[0]+mat.mtr.v[1].v[1]+mat.mtr.v[2].v[2];
  if traceMat>EPSILON2 then begin
    s:=Sqrt(traceMat)*2;
    invS:=1/s;
    Result.ImagPart.x:=(mat.mtr.v[1].v[2]-mat.mtr.v[2].v[1])*invS;
    Result.ImagPart.y:=(mat.mtr.v[2].v[0]-mat.mtr.v[0].v[2])*invS;
    Result.ImagPart.z:=(mat.mtr.v[0].v[1]-mat.mtr.v[1].v[0])*invS;
    Result.RealPart:=0.25*s;
  end else if (mat.mtr.v[0].v[0]>mat.mtr.v[1].v[1]) and (mat.mtr.v[0].v[0]>mat.mtr.v[2].v[2]) then begin  // Row 0:
    s:=Sqrt(Max(EPSILON2,1+mat.mtr.v[0].v[0]-mat.mtr.v[1].v[1]-mat.mtr.v[2].v[2]))*2;
    invS:=1/s;
    Result.ImagPart.x:=0.25*s;
    Result.ImagPart.y:=(mat.mtr.v[0].v[1]+mat.mtr.v[1].v[0])*invS;
    Result.ImagPart.z:=(mat.mtr.v[2].v[0]+mat.mtr.v[0].v[2])*invS;
    Result.RealPart:=(mat.mtr.v[1].v[2]-mat.mtr.v[2].v[1])*invS;
  end else if (mat.mtr.v[1].v[1]>mat.mtr.v[2].v[2]) then begin  // Row 1:
    s:=Sqrt(Max(EPSILON2,1+mat.mtr.v[1].v[1]-mat.mtr.v[0].v[0]-mat.mtr.v[2].v[2]))*2;
    invS:=1/s;
    Result.ImagPart.x:=(mat.mtr.v[0].v[1]+mat.mtr.v[1].v[0])*invS;
    Result.ImagPart.y:=0.25*s;
    Result.ImagPart.z:=(mat.mtr.v[1].v[2]+mat.mtr.v[2].v[1])*invS;
    Result.RealPart:=(mat.mtr.v[2].v[0]-mat.mtr.v[0].v[2])*invS;
  end else begin  // Row 2:
    s:=Sqrt(Max(EPSILON2,1+mat.mtr.v[2].v[2]-mat.mtr.v[0].v[0]-mat.mtr.v[1].v[1]))*2;
    invS:=1/s;
    Result.ImagPart.x:=(mat.mtr.v[2].v[0]+mat.mtr.v[0].v[2])*invS;
    Result.ImagPart.y:=(mat.mtr.v[1].v[2]+mat.mtr.v[2].v[1])*invS;
    Result.ImagPart.z:=0.25*s;
    Result.RealPart:=(mat.mtr.v[0].v[1]-mat.mtr.v[1].v[0])*invS;
  end;
  NormalizeQuaternion(Result);
end;

function QuaternionSlerp(const Source,dest:TzeQuaternion;const t:double):TzeQuaternion;
var
  to1:array[0..4] of single;
  omega,cosom,sinom,scale0,scale1:extended;
begin
  // calc cosine
  cosom:= source.ImagPart.x*dest.ImagPart.x
         +source.ImagPart.y*dest.ImagPart.y
         +source.ImagPart.z*dest.ImagPart.z
         +source.RealPart  *dest.RealPart;
  // adjust signs (if necessary)
  if cosom<0 then begin
    cosom:=-cosom;
    to1[0]:=-dest.ImagPart.x;
    to1[1]:=-dest.ImagPart.y;
    to1[2]:=-dest.ImagPart.z;
    to1[3]:=-dest.RealPart;
  end else begin
    to1[0]:=dest.ImagPart.x;
    to1[1]:=dest.ImagPart.y;
    to1[2]:=dest.ImagPart.z;
    to1[3]:=dest.RealPart;
  end;
  // calculate coefficients
  if ((1.0-cosom)>EPSILON2) then begin // standard case (slerp)
     omega:=ArcCos(cosom);
     sinom:=1/Sin(omega);
     scale0:=Sin((1.0-t)*omega)*sinom;
     scale1:=Sin(t*omega)*sinom;
  end else begin // "from" and "to" quaternions are very close
                 //  ... so we can do a linear interpolation
    scale0:=1.0-t;
    scale1:=t;
  end;
  // calculate final values
  Result.ImagPart.x:=scale0*Source.ImagPart.x+scale1*to1[0];
  Result.ImagPart.y:=scale0*Source.ImagPart.y+scale1*to1[1];
  Result.ImagPart.z:=scale0*Source.ImagPart.z+scale1*to1[2];
  Result.RealPart:=scale0*Source.RealPart+scale1*to1[3];
  NormalizeQuaternion(Result);
end;

function QuaternionToMatrix(quat:TzeQuaternion):TzeTypedMatrix4d;
var
  w,x,y,z,xx,xy,xz,xw,yy,yz,yw,zz,zw:double;
begin
  Result.CreateRec(cOneMtr,CMTRotate);
  NormalizeQuaternion(quat);
  w:=quat.RealPart;
  x:=quat.ImagPart.x;
  y:=quat.ImagPart.y;
  z:=quat.ImagPart.z;
  xx:=x*x;
  xy:=x*y;
  xz:=x*z;
  xw:=x*w;
  yy:=y*y;
  yz:=y*z;
  yw:=y*w;
  zz:=z*z;
  zw:=z*w;
  Result.mtr.v[0].v[0]:=1-2*(yy+zz);
  Result.mtr.v[1].v[0]:=2*(xy-zw);
  Result.mtr.v[2].v[0]:=2*(xz+yw);
  Result.mtr.v[3].v[0]:=0;
  Result.mtr.v[0].v[1]:=2*(xy+zw);
  Result.mtr.v[1].v[1]:=1-2*(xx+zz);
  Result.mtr.v[2].v[1]:=2*(yz-xw);
  Result.mtr.v[3].v[1]:=0;
  Result.mtr.v[0].v[2]:=2*(xz-yw);
  Result.mtr.v[1].v[2]:=2*(yz+xw);
  Result.mtr.v[2].v[2]:=1-2*(xx+yy);
  Result.mtr.v[3].v[2]:=0;
  Result.mtr.v[0].v[3]:=0;
  Result.mtr.v[1].v[3]:=0;
  Result.mtr.v[2].v[3]:=0;
  Result.mtr.v[3].v[3]:=1;
end;

function GetArcParamFrom3Point2D(const PointData:tarcrtmodify;out ad:TArcData):boolean;
var
  a,b,c,d,e,f,g,rr:double;
  tv:TzePoint2d;
begin
  A:=PointData.p2.x-PointData.p1.x;
  B:=PointData.p2.y-PointData.p1.y;
  C:=PointData.p3.x-PointData.p1.x;
  D:=PointData.p3.y-PointData.p1.y;

  E:=A*(PointData.p1.x+PointData.p2.x)+B*(PointData.p1.y+PointData.p2.y);
  F:=C*(PointData.p1.x+PointData.p3.x)+D*(PointData.p1.y+PointData.p3.y);

  G:=2*(A*(PointData.p3.y-PointData.p2.y)-B*(PointData.p3.x-PointData.p2.x));
  if abs(g)>eps then begin
    Result:=true;
    ad.p.x:=(D*E-B*F)/G;
    ad.p.y:=(A*F-C*E)/G;
    ad.r:=sqrt(sqr(PointData.p1.x-ad.p.x)+sqr(PointData.p1.y-ad.p.y));
    tv.x:=ad.p.x;
    tv.y:=ad.p.y;
    ad.startangle:=VectorAngle(PointData.p1-tv);
    ad.endangle:=VectorAngle(PointData.p3-tv);
    if ad.startangle>ad.endangle then begin
      rr:=ad.startangle;
      ad.startangle:=ad.endangle;
      ad.endangle:=rr;
    end;
    rr:=VectorAngle(PointData.p2-tv);
    if not((rr>ad.startangle)and(rr<ad.endangle)) then begin
      rr:=ad.startangle;
      ad.startangle:=ad.endangle;
      ad.endangle:=rr;
    end;
  end else
    Result:=false;
end;

function myPickMatrix(const x,y,deltax,deltay:double;const vp:TzeVector4i):TzeTypedMatrix4d;
var
  tm,sm:TzeTypedMatrix4d;
begin
  tm:=CreateTranslationMatrix(TzeVector3d.Make((vp.v[2]-2*(x-vp.v[0]))/deltax,(vp.v[3]-2*(y-vp.v[1]))/deltay,0));
  sm:=CreateScaleMatrix(TzeVector3d.Make(vp.v[2]/deltax,vp.v[3]/deltay,1.0));
  Result:=MatrixMultiply(sm,tm);
  Result.t:=CMTTransform;
end;

function CalcDisplaySubFrustum(const x,y,w,h:double;const mm,pm:TzeTypedMatrix4d;const vp:TzeVector4i):TzeFrustum;
var
  tm:TzeTypedMatrix4d;
begin
  //use glu.gluPickMatrix
  tm:=myPickMatrix(x,y,w,h,vp);
  tm:=MatrixMultiply(pm,tm);
  tm:=MatrixMultiply(mm,tm);
  Result:=calcfrustum(@tm);
end;

function GetCSDirFrom0x0y2D(const ox,oy:TzeVector3d):TCSDir;
begin
  if vectordot(ox,oy).z>eps then
    Result:=TCSDLeft
  else
    Result:=TCSDRight;
end;

function CalcTrueInFrustum(const lbegin,lend:TzePoint3d;const frustum:TzeFrustum):TInBoundingVolume;
var
  i,j:integer;
  d1,d2:double;
  bytebegin,byteend,bit:integer;
  ca:TLineClipArray;
  cacount:integer;
  d:TzeVector3d;
  p:TzePoint3d;
begin
  fillchar((@ca)^,sizeof(ca),0);
  Result:=IREmpty;
  bit:=1;
  bytebegin:=0;
  byteend:=0;
  cacount:=0;
  for i:=0 to 5 do begin
    with frustum.v[i] do begin
      d1:=v[0]*lbegin.x+v[1]*lbegin.y+v[2]*lbegin.z+v[3];
      d2:=v[0]*lend.x+v[1]*lend.y+v[2]*lend.z+v[3];
    end;
    if d1<0 then
      bytebegin:=bytebegin or bit;
    if d2<0 then
      byteend:=byteend or bit;
    if ((bytebegin and bit)and(byteend and bit))>0 then begin
      Result:=IREmpty;
      exit;
    end;
    if ((bytebegin and bit)xor(byteend and bit))>0 then begin
      d1:=abs(d1);
      d2:=abs(d2);
      ca[cacount]:=d1/(d1+d2);
      Inc(cacount);
    end;
    bit:=bit*2;
  end;
  if ((bytebegin)=0)and((byteend)=0) then begin
    Result:=IRFully;
    exit;
  end;
  if (bytebegin)=0 then begin
    Result:=IRPartially;
    exit;
  end;
  if (byteend)=0 then begin
    Result:=IRPartially;
    exit;
  end;
  if cacount<2 then begin
    Result:=IREmpty;
    exit;
  end;
  Dec(cacount);
  d:=lend-lbegin;
  j:=0;
  d1:=GetMinAndSwap(j,cacount,ca);
  while j<=cacount do begin
    d2:=GetMinAndSwap(j,cacount,ca);
    d1:=(d1+d2)/2;
    bit:=0;
    p:=lbegin+d*d1;
    for i:=0 to 5 do begin
      with frustum.v[i] do
        if (v[0]*p.x+v[1]*p.y+v[2]*p.z+v[3])>=0 then
          Inc(bit);
    end;
    if bit=6 then begin
      Result:=IRPartially;
      exit;
    end;
    d1:=d2;
  end;
end;

function CalcTrueInFrustum(const lbegin,lend:TzePoint3s;const frustum:TzeFrustum):TInBoundingVolume;
var
  i,j:integer;
  d1,d2:double;
  bytebegin,byteend,bit:integer;
  ca:TLineClipArray;
  cacount:integer;
  d:TzeVector3s;
  p:TzePoint3s;
begin
  fillchar((@ca)^,sizeof(ca),0);
  Result:=IREmpty;
  bit:=1;
  bytebegin:=0;
  byteend:=0;
  cacount:=0;
  for i:=0 to 5 do begin
    with frustum.v[i] do begin
      d1:=v[0]*lbegin.x+v[1]*lbegin.y+v[2]*lbegin.z+v[3];
      d2:=v[0]*lend.x+v[1]*lend.y+v[2]*lend.z+v[3];
    end;
    if d1<0 then
      bytebegin:=bytebegin or bit;
    if d2<0 then
      byteend:=byteend or bit;
    if ((bytebegin and bit)and(byteend and bit))>0 then begin
      Result:=IREmpty;
      exit;
    end;
    if ((bytebegin and bit)xor(byteend and bit))>0 then begin
      d1:=abs(d1);
      d2:=abs(d2);
      ca[cacount]:=d1/(d1+d2);
      Inc(cacount);
    end;
    bit:=bit*2;
  end;
  if ((bytebegin)=0)and((byteend)=0) then begin
    Result:=IRFully;
    exit;
  end;
  if (bytebegin)=0 then begin
    Result:=IRPartially;
    exit;
  end;
  if (byteend)=0 then begin
    Result:=IRPartially;
    exit;
  end;
  if cacount<2 then begin
    Result:=IREmpty;
    exit;
  end;
  Dec(cacount);
  d:=lend-lbegin;
  j:=0;
  d1:=GetMinAndSwap(j,cacount,ca);
  while j<=cacount do begin
    d2:=GetMinAndSwap(j,cacount,ca);
    d1:=(d1+d2)/2;
    bit:=0;
    p:=lbegin+d*d1;
    for i:=0 to 5 do begin
      with frustum.v[i] do
        if (v[0]*p.x+v[1]*p.y+v[2]*p.z+v[3])>=0 then
          Inc(bit);
    end;
    if bit=6 then begin
      Result:=IRPartially;
      exit;
    end;
    d1:=d2;
  end;
end;

function CalcAABBInFrustum(const AABB:TBoundingBox;const frustum:TzeFrustum):TInBoundingVolume;
var
  i,Count:integer;
  p1,p2,p3,p4,p5,p6,p7,p8:TzePoint3d;
  d1,d2,d3,d4,d5,d6,d7,d8:double;
begin
  p1:=AABB.pMin;
  p2:=TzePoint3d.Make(AABB.pMax.x,AABB.pMin.y,AABB.pMin.Z);
  p3:=TzePoint3d.Make(AABB.pMax.x,AABB.pMax.y,AABB.pMin.Z);
  p4:=TzePoint3d.Make(AABB.pMin.x,AABB.pMax.y,AABB.pMin.Z);
  p5:=TzePoint3d.Make(AABB.pMin.x,AABB.pMin.y,AABB.pMax.Z);
  p6:=TzePoint3d.Make(AABB.pMax.x,AABB.pMin.y,AABB.pMax.Z);
  p7:=AABB.pMax;
  p8:=TzePoint3d.Make(AABB.pMin.x,AABB.pMax.y,AABB.pMax.Z);

  Count:=0;
  for i:=0 to 5 do begin
    with frustum.v[i] do begin
      d1:=v[0]*p1.x+v[1]*p1.y+v[2]*p1.z+v[3];
      d2:=v[0]*p2.x+v[1]*p2.y+v[2]*p2.z+v[3];
      d3:=v[0]*p3.x+v[1]*p3.y+v[2]*p3.z+v[3];
      d4:=v[0]*p4.x+v[1]*p4.y+v[2]*p4.z+v[3];
      d5:=v[0]*p5.x+v[1]*p5.y+v[2]*p5.z+v[3];
      d6:=v[0]*p6.x+v[1]*p6.y+v[2]*p6.z+v[3];
      d7:=v[0]*p7.x+v[1]*p7.y+v[2]*p7.z+v[3];
      d8:=v[0]*p8.x+v[1]*p8.y+v[2]*p8.z+v[3];
    end;

    if (d1<0)and(d2<0)and(d3<0)and(d4<0)and(d5<0)and(d6<0)and  (d7<0)and(d8<0) then begin
      Result:=IREmpty;
      system.exit;
    end;

    if d1>=0 then
      Inc(Count);
    if d2>=0 then
      Inc(Count);
    if d3>=0 then
      Inc(Count);
    if d4>=0 then
      Inc(Count);
    if d5>=0 then
      Inc(Count);
    if d6>=0 then
      Inc(Count);
    if d7>=0 then
      Inc(Count);
    if d8>=0 then
      Inc(Count);
  end;
  Result:=IRPartially;
  if Count=48 then begin
    Result:=irfully;
  end;
end;

function PointOf3PlaneIntersect(const P1,P2,P3:TzeVector4d):TzePoint3d;
var
  N1,N2,N3,N12,N23,N31,a1,a2,a3:TzeVector3d;
  a4:double;
begin
  Result:=cP3d__0__0__0;
  n1:=p1.Slice;
  n2:=p2.Slice;;
  n3:=p3.Slice;
  n12:=vectordot(n1,n2);
  n23:=vectordot(n2,n3);
  n31:=vectordot(n3,n1);

  a1:=n23*p1.CutOff;
  a2:=n31*p2.CutOff;
  a3:=n12*p3.CutOff;
  a4:=ScalarDot(n1,n23);
  if abs(a4)<eps then
    exit;
  a4:=1/a4;
  a1:=a1+a2;
  a1:=a1+a3;

  Result:=(a1*-a4).asPoint3d;
end;

function PointOfRayPlaneIntersect(const p1:TzePoint3d;const d:TzeVector3d;const plane:TzeVector4d;out point:TzePoint3d):boolean;
var
  td:double;
begin
  with TzeVector4d((@plane)^) do
    td:=-v[0]*d.x-v[1]*d.y-v[2]*d.z;

  if abs(td)<eps then
    exit(false);

  with TzeVector4d((@plane)^) do
    td:=(v[0]*p1.x+v[1]*p1.y+v[2]*p1.z+v[3])/td;

  point:=p1+d*td;
  Result:=true;
end;

function PointOfRayPlaneIntersect(const p1:TzePoint3d;const d:TzeVector3d;const plane:TzeVector4d;out t:double):boolean;
var
  td:double;
begin
  with TzeVector4d((@plane)^) do
    td:=-v[0]*d.x-v[1]*d.y-v[2]*d.z;

  if abs(td)<eps then
    exit(false);

  with TzeVector4d((@plane)^) do
    t:=(v[0]*p1.x+v[1]*p1.y+v[2]*p1.z+v[3])/td;
  if (t>=0)and(t<=1) then
    Result:=true
  else
    Result:=false;
end;

function Ortho(const xmin,xmax,ymin,ymax,zmin,zmax:Double;const matrix:PzeTypedMatrix4d):TzeTypedMatrix4d;
var
  xmaxminusxmin,ymaxminusymin,zmaxminuszmin,xmaxplusxmin,ymaxplusymin,zmaxpluszmin:double;
  m:TzeTypedMatrix4d;
begin
  xmaxminusxmin:=xmax-xmin;
  ymaxminusymin:=ymax-ymin;
  zmaxminuszmin:=-(zmax-zmin);
  xmaxplusxmin:=xmax+xmin;
  ymaxplusymin:=ymax+ymin;
  zmaxpluszmin:=zmax+zmin;
  if (abs(xmaxminusxmin)<eps) or  (abs(ymaxminusymin)<eps) or  (abs(zmaxminuszmin)<eps) then
    exit(matrix^);

  m.CreateRec(cOneMtr,CMTTransform);
  {Все коэффициенты домножены на xmaxminusxmin, восстановить оригинал - соответственно всё разделить}
  m.mtr.v[0].v[0]:=2{/xmaxminusxmin};
  m.mtr.v[1].v[1]:=(2/ymaxminusymin)*xmaxminusxmin;
  m.mtr.v[2].v[2]:=(2/zmaxminuszmin)*xmaxminusxmin;
  m.mtr.v[3].v[0]:=(-xmaxplusxmin/xmaxminusxmin)*xmaxminusxmin;
  m.mtr.v[3].v[1]:=(-ymaxplusymin/ymaxminusymin)*xmaxminusxmin;
  m.mtr.v[3].v[2]:=(zmaxpluszmin/zmaxminuszmin)*xmaxminusxmin;
  m.mtr.v[3].v[3]:=xmaxminusxmin;

  Result:=MatrixMultiply(m,matrix^);
  //glMultMatrixd(@m);
end;

function Perspective(const fovy,W_H,zmin,zmax:Double;const matrix:PzeTypedMatrix4d):TzeTypedMatrix4d;
var
  sine,cosine,cotangent,deltaZ,radians:double;
  m:TzeTypedMatrix4d;
begin
  radians:=fovy/2*Pi/180;
  deltaZ:=zmax-zmin;
  SinCos(radians,sine,cosine);
  cotangent:=cosine/sine;
  m.CreateRec(cOneMtr,CMTTransform);
  m.mtr.v[0].v[0]:=cotangent/w_h;
  m.mtr.v[1].v[1]:=cotangent;
  m.mtr.v[2].v[2]:=-(zmax+zmin)/deltaZ;
  m.mtr.v[2].v[3]:=-1;
  m.mtr.v[3].v[2]:=-2*zmin*zmax/deltaZ;
  m.mtr.v[3].v[3]:=0;
  Result:=MatrixMultiply(m,matrix^);
end;

function lookat(point:TzePoint3d;ex,ey,ez:TzeVector3d;const matrix:PzeTypedMatrix4d):TzeTypedMatrix4d;
var
  m:TzeTypedMatrix4d;
  m2:TzeTypedMatrix4d;
begin
  m:=CreateMatrixFromBasis(-ex,ey,-ez);
  MatrixTranspose(m);
  m2:=CreateTranslationMatrix(point.asVector);
  m:=MatrixMultiply(m2,m);
  Result:=MatrixMultiply(m,matrix^);
end;

procedure _myGluUnProject(const winx,winy,winz:double;const modelMatrix,projMatrix:PzeTypedMatrix4d;const viewport:PzeVector4i;out objx,objy,objz:double);
var
  _in,_out:TzeVector4d;
  finalMatrix:TzeTypedMatrix4d;
begin
  finalMatrix:=MatrixMultiply(modelMatrix^,projMatrix^);
  MatrixInvert(finalMatrix);

  _in.x:=winx;
  _in.y:=winy;
  _in.z:=winz;
  _in.w:=1.0;

  _in.x:=(_in.x-viewport^.v[0])/viewport^.v[2];
  _in.y:=(_in.y-viewport^.v[1])/viewport^.v[3];

  //* Map to range -1 to 1 */
  _in.x:=_in.x*2-1;
  _in.y:=_in.y*2-1;
  _in.z:=_in.z*2-1;

  _out:=VectorTransform(_in,finalMatrix);

  objx:=_out.x/_out.w;
  objy:=_out.y/_out.w;
  objz:=_out.z/_out.w;
end;

procedure _myGluProject(const objx,objy,objz:double;const modelMatrix,projMatrix:PzeTypedMatrix4d;const viewport:PzeVector4i;out winx,winy,winz:double);
var
  _in:TzeVector4d;
begin
  _in.x:=objx;
  _in.y:=objy;
  _in.z:=objz;
  _in.w:=1.0;
  _in:=VectorTransform(VectorTransform(_in,modelMatrix^),projMatrix^);

  _in.x:=_in.x/_in.w;
  _in.y:=_in.y/_in.w;
  _in.z:=_in.z/_in.w;

  //* Map x, y and z to range 0-1 */
  _in.x:=_in.x*0.5+0.5;
  _in.y:=_in.y*0.5+0.5;
  _in.z:=_in.z*0.5+0.5;

  //* Map x,y to viewport */
  winx:=_in.x*viewport^.v[2]+viewport^.v[0];
  winy:=_in.y*viewport^.v[3]+viewport^.v[1];
  winz:=_in.z;
end;

procedure _myGluProject2(const objcoord:TzePoint3d;const modelMatrix,projMatrix:PzeTypedMatrix4d;const viewport:PzeVector4i;out wincoord:TzePoint3d);
begin
  _myGluProject(objcoord.x,objcoord.y,objcoord.z,modelMatrix,projMatrix,viewport,wincoord.x,wincoord.y,wincoord.z);
end;

function SQRdist_Point_to_Segment(const p,s0,s1:TzePoint3d):double;
var
  v,w,pb:TzeVector3d;
  c1,c2,b:double;
begin
  v:=s1-s0;
  w:=p-s0;

  c1:=ScalarDot(w,v);
  if c1<=0 then begin
    Result:=p.SqrLengthTo(s0);
    exit;
  end;

  c2:=ScalarDot(v,v);
  if c2<=c1 then begin
    Result:=p.SqrLengthTo(s1);
    exit;
  end;

  b:=c1/c2;
  Pb:=s0.asVector+(v*b);
  Result:=p.SqrLengthTo(pb.asPoint3d);
end;

function NearestPointOnSegment(const p,s0,s1:TzePoint3d):TzePoint3d;
var
  v,w:TzeVector3d;
  c1,c2:double;
begin
  v:=s1-s0;
  w:=p-s0;

  c1:=ScalarDot(w,v);
  if c1<=0 then
    exit(s0);

  c2:=ScalarDot(v,v);
  if c2<=c1 then
    exit(s1);

  Result:=s0+v*(c1/c2);
end;

function distance2ray(const q,p1,p2:TzePoint3d):TDistWitht;
var
  w,v:TzeVector3d;
  c1,c2:double;
begin
  v:=p2-p1;
  w:=q-p1;
  c1:=ScalarDot(w,v);
  c2:=ScalarDot(v,v);
  if abs(c2)>eps then begin
    Result.t:=c1/c2;
    Result.d:=q.LengthTo(p1+v*Result.t);
  end else begin
    Result.t:=0;
    Result.d:=q.LengthTo(p1);
  end;
end;

function CreateAffineRotationMatrix(const anAxis:TzeVector3d;angle:double):TzeTypedMatrix4d;
var
  axis:TzeVector3d;
  cosine,sine,one_minus_cosine:double;
begin
  SinCos(angle,SINE,cosine);
  one_minus_cosine:=1-cosine;
  axis:=anAxis.Normalized;

  Result.CreateRec(cOneMtr,CMTRotate);
  Result.mtr.v[cxAxisIndex].v[cxAxisIndex]:=(one_minus_cosine*Sqr(Axis.x))+Cosine;
  Result.mtr.v[cxAxisIndex].v[cyAxisIndex]:=(one_minus_cosine*Axis.x*Axis.y)-(Axis.z*Sine);
  Result.mtr.v[cxAxisIndex].v[czAxisIndex]:=(one_minus_cosine*Axis.z*Axis.x)+(Axis.y*Sine);

  Result.mtr.v[cyAxisIndex].v[cxAxisIndex]:=(one_minus_cosine*Axis.x*Axis.y)+(Axis.z*Sine);
  Result.mtr.v[cyAxisIndex].v[cyAxisIndex]:=(one_minus_cosine*Sqr(Axis.y))+Cosine;
  Result.mtr.v[cyAxisIndex].v[czAxisIndex]:=(one_minus_cosine*Axis.y*Axis.z)-(Axis.x*Sine);

  Result.mtr.v[czAxisIndex].v[cxAxisIndex]:=(one_minus_cosine*Axis.z*Axis.x)-(Axis.y*Sine);
  Result.mtr.v[czAxisIndex].v[cyAxisIndex]:=(one_minus_cosine*Axis.y*Axis.z)+(Axis.x*Sine);
  Result.mtr.v[czAxisIndex].v[czAxisIndex]:=(one_minus_cosine*Sqr(Axis.z))+Cosine;
end;

function CreateAffineRotationMatrix(const AAxis,ARefV,AV:TzeVector3d):TzeTypedMatrix4d;
var
  Angle:double;
begin
  Angle:=twoVectorAngle(ARefV,AV);
  if VectorDot(ARefV,AV).z>0 then
    Angle:=2*pi-Angle;
  Result:=CreateAffineRotationMatrix(AAxis,Angle);
end;

function TwoVectorAngle(const Vector1,Vector2:TzeVector3d):double;inline;
begin
  Result:=ArcCos(ScalarDot(Vector1,Vector2));
end;

function intercept3d(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;
var
  t1,t2:double;
  p13,p43,p21,pp:TzePoint3d;
  d1343,d4321,d1321,d4343,d2121,numer,denom:double;
begin
  Result.isintercept:=false;
  p13.x:=l1begin.x-l2begin.x;
  p13.y:=l1begin.y-l2begin.y;
  p13.z:=l1begin.z-l2begin.z;
  p43.x:=l2end.x-l2begin.x;
  p43.y:=l2end.y-l2begin.y;
  p43.z:=l2end.z-l2begin.z;
  if (ABS(p43.x)<EPS) and (ABS(p43.y)<EPS) and (ABS(p43.z)<EPS) then
    exit;
  p21.x:=l1end.x-l1begin.x;
  p21.y:=l1end.y-l1begin.y;
  p21.z:=l1end.z-l1begin.z;
  if (ABS(p21.x)<EPS) and (ABS(p21.y)<EPS) and (ABS(p21.z)<EPS) then
    exit;

  d1343:=p13.x*p43.x+p13.y*p43.y+p13.z*p43.z;
  d4321:=p43.x*p21.x+p43.y*p21.y+p43.z*p21.z;
  d1321:=p13.x*p21.x+p13.y*p21.y+p13.z*p21.z;
  d4343:=p43.x*p43.x+p43.y*p43.y+p43.z*p43.z;
  d2121:=p21.x*p21.x+p21.y*p21.y+p21.z*p21.z;

  denom:=d2121*d4343-d4321*d4321;
  if (ABS(denom)< {EPS}sqreps) then begin
    //бывают случаи соприкосновения линий концами, их надо обработать
    if l1begin.IsEqual(l2begin) then begin
      Result.isintercept:=true;
      Result.t1:=0;
      Result.t2:=0;
      Result.interceptcoord:=l1begin;
      exit;
    end else if l1begin.IsEqual(l2end) then begin
      Result.isintercept:=true;
      Result.t1:=0;
      Result.t2:=1;
      Result.interceptcoord:=l1begin;
      exit;
    end else if l1end.IsEqual(l2begin) then begin
      Result.isintercept:=true;
      Result.t1:=1;
      Result.t2:=0;
      Result.interceptcoord:=l1end;
      exit;
    end else if l1end.IsEqual(l2end) then begin
      Result.isintercept:=true;
      Result.t1:=1;
      Result.t2:=1;
      Result.interceptcoord:=l1end;
      exit;
    end;
    exit;
  end;

  numer:=d1343*d4321-d1321*d4343;

  Result.t1:=numer/denom;
  Result.t2:=(d1343+d4321*Result.t1)/d4343;
  t1:=Result.t1;
  t2:=Result.t2;

  if abs(Result.t1-1)<bigeps then
    Result.t1:=1;
  if abs(Result.t1)<bigeps then
    Result.t1:=0;
  if abs(Result.t2-1)<bigeps then
    Result.t2:=1;
  if abs(Result.t2)<bigeps then
    Result.t2:=0;
  if ((Result.t1<=1) and (Result.t1>=0) and (Result.t2>=0) and (Result.t2<=1)) then begin
    Result.interceptcoord:=TzePoint3d.Make(l1begin.x+t1*p21.x,l1begin.y+t1*p21.y,l1begin.z+t1*p21.z);
    //result.interceptcoord:=TzePoint3d.Make([l1begin.x+t1*p21.x,l1begin.y+t1*p21.y,l1begin.z+t1*p21.z]);
    {result.interceptcoord.x:= l1begin.x + t1 * p21.x;
    result.interceptcoord.y:= l1begin.y + t1 * p21.y;
    result.interceptcoord.z:= l1begin.z + t1 * p21.z;}
    pp.x:=l2begin.x+t2*p43.x;
    pp.y:=l2begin.y+t2*p43.y;
    pp.z:=l2begin.z+t2*p43.z;

    //todo: непомню зачем добавил эту проверку, по сути она не нужна - пересечение
    //всеравно "насчитали". Координаты на линиях могут не совпасть изза
    //погрешности, что собсвенно происходит при пересечении вот этих линий
    //(5865965.88288733,-2925099.80152868)-(5865959.78288733,-2925099.80152868)
    //(5865964.13288733,-2925101.55152868)-(5865964.13288733,-2925098.05152868)
    //пока отодвинуд точность с bigEPS на floateps, но по идее надо убрать
    //если не вспомню зачем добавлял

    if (ABS(pp.x-Result.interceptcoord.x)>floateps) or  (ABS(pp.y-Result.interceptcoord.y)>floateps) or
      (ABS(pp.z-Result.interceptcoord.z)>floateps) then
      exit;
    Result.isintercept:=true;
  end;
end;

function CreateDoubleFromArray(var counter:integer;const args:array of const):double;
begin
  case args[counter].VType of
    vtInteger:Result:=args[counter].VInteger;
    vtExtended:Result:=args[counter].VExtended^;
    else
      zDebugLn('{E}CreateDoubleFromArray: not Integer, not Extended');
  end;{case}
  Inc(counter);
end;

function CreateBooleanFromArray(var counter:integer;const args:array of const):boolean;
begin
  case args[counter].VType of
    vtBoolean:Result:=args[counter].VBoolean;
    else
      zDebugLn('{E}CreateStrinBooleanFromArray: not boolean');
  end;{case}
  Inc(counter);
end;

function CreateVertex2DFromArray(var counter:integer;const args:array of const):TzePoint2d;
begin
  if (counter+1)<=(high(args)) then begin
    with TzePoint2d((@Result)^) do begin
      x:=CreateDoubleFromArray(counter,args);
      y:=CreateDoubleFromArray(counter,args);
    end;
  end else begin
    zDebugLn('{E}CreateVertex2DFromArray: no enough params in args');
  end;
end;

function CreateVertexFromArray(var counter:integer;const args:array of const):TzePoint3d;
begin
  if (counter+2)<=(high(args)) then begin
    with TzePoint3d((@Result)^) do begin
      x:=CreateDoubleFromArray(counter,args);
      y:=CreateDoubleFromArray(counter,args);
      z:=CreateDoubleFromArray(counter,args);
    end;
  end else begin
    zDebugLn('{E}CreateVertexFromArray: no enough params in args');
  end;
end;

function GetXfFromZ(const oz:TzeVector3d):TzeVector3d;
begin
  if IsNearToZ(oz)then
    result:=VectorDot(cV3d__0__1__0,oz)
  else
    result:=VectorDot(cV3d__0__0__1,oz);
  result.Normalize;
end;

function GetPointInOCSByBasis(const ScaledBX,ScaledBY,ScaledBZ:TzeVector3d; const PointInWCS:TzePoint3d; out scale:TzeVector3d):GDBObj2dprop;
var
  BX,BY,BZ:TzeVector3d;
begin
  scale.x:=ScaledBX.Length;
  scale.y:=ScaledBY.Length;
  scale.z:=ScaledBZ.Length;
  if (abs(scale.x)>eps)and(abs(scale.y)>eps)and(abs(scale.z)>eps)then begin

    BX:=ScaledBX/scale.x;
    BY:=ScaledBY/scale.y;
    BZ:=ScaledBZ/scale.z;


    if ScalarDot(BX,VectorDot(BY,Bz))<0 then
      scale.x:=-scale.x;

    result.Basis.ox:=BX;
    result.Basis.oy:=BY;
    result.Basis.oz:=BZ;

    BX:=GetXfFromZ(BZ).Normalized;
    BY:=VectorDot(BZ,Bx).Normalized;

    //вариант из https://ezdxf.readthedocs.io/en/stable/concepts/ocs.html#arbitrary-axis-algorithm
    result.P_insert.x:=PointInWCS.x*BX.x+PointInWCS.y*BX.y+PointInWCS.z*BX.z;
    result.P_insert.y:=PointInWCS.x*BY.x+PointInWCS.y*BY.y+PointInWCS.z*BY.z;
    result.P_insert.z:=PointInWCS.x*BZ.x+PointInWCS.y*BZ.y+PointInWCS.z*BZ.z;

    //вариант расчета без учета что базисные векторы ортогональны
    (*
    //  -((-BY.z*BZ.y*PointInWCS.x+BY.y*BZ.z*PointInWCS.x+BY.z*BZ.x*PointInWCS.y-BY.x*BZ.z*PointInWCS.y-BY.y*BZ.x*PointInWCS.z+BY.x*BZ.y*PointInWCS.z)
    //X=--------------------------------------------------------------------------------------------
    //  (BX.z*BY.y*BZ.x-BX.y*BY.z*BZ.x-BX.z*BY.x*BZ.y+BX.x*BY.z*BZ.y+BX.y*BY.x*BZ.z-BX.x*BY.y*BZ.z))

    //  -((BX.z*BZ.y*PointInWCS.x-BX.y*BZ.z*PointInWCS.x-BX.z*BZ.x*PointInWCS.y+BX.x*BZ.z*PointInWCS.y+BX.y*BZ.x*PointInWCS.z-BX.x*BZ.y*PointInWCS.z)
    //Y=--------------------------------------------------------------------------------------------
    //  (BX.z*BY.y*BZ.x-BX.y*BY.z*BZ.x-BX.z*BY.x*BZ.y+BX.x*BY.z*BZ.y+BX.y*BY.x*BZ.z-BX.x*BY.y*BZ.z))

    //  -((-BX.z*BY.y*PointInWCS.x+BX.y*BY.z*PointInWCS.x+BX.z*BY.x*PointInWCS.y-BX.x*BY.z*PointInWCS.y-BX.y*BY.x*PointInWCS.z+BX.x*BY.y*PointInWCS.z)
    //Z=--------------------------------------------------------------------------------------------
    //  (BX.z*BY.y*BZ.x-BX.y*BY.z*BZ.x-BX.z*BY.x*BZ.y+BX.x*BY.z*BZ.y+BX.y*BY.x*BZ.z-BX.x*BY.y*BZ.z))

    tznam:=BX.z*BY.y*BZ.x-BX.y*BY.z*BZ.x-BX.z*BY.x*BZ.y+BX.x*BY.z*BZ.y+BX.y*BY.x*BZ.z-BX.x*BY.y*BZ.z;
    if abs(tznam)>eps then begin
      tr:=-BY.z*BZ.y*PointInWCS.x+BY.y*BZ.z*PointInWCS.x+BY.z*BZ.x*PointInWCS.y-BY.x*BZ.z*PointInWCS.y-BY.y*BZ.x*PointInWCS.z+BY.x*BZ.y*PointInWCS.z;
      result.P_insert.x:=-tr/tznam;
      tr:=BX.z*BZ.y*PointInWCS.x-BX.y*BZ.z*PointInWCS.x-BX.z*BZ.x*PointInWCS.y+BX.x*BZ.z*PointInWCS.y+BX.y*BZ.x*PointInWCS.z-BX.x*BZ.y*PointInWCS.z;
      result.P_insert.y:=-tr/tznam;
      tr:=-BX.z*BY.y*PointInWCS.x+BX.y*BY.z*PointInWCS.x+BX.z*BY.x*PointInWCS.y-BX.x*BY.z*PointInWCS.y-BX.y*BY.x*PointInWCS.z+BX.x*BY.y*PointInWCS.z;
      result.P_insert.z:=-tr/tznam;
    end;
    *)
  end;
end;

function intercept2dmy(const l1begin,l1end,l2begin,l2end:TzePoint2d):intercept2dprop;
var
  _t1,_t2,d:double;
begin
  Result.isintercept:=false;
  D:=(l1end.y-l1begin.y)*(l2begin.x-l2end.x)-(l2begin.y-l2end.y)*(l1end.x-l1begin.x);
  if (D<>0) then begin
    _t1:=((l1end.y-l1begin.y)*(l2begin.x-l1begin.x)-(l2begin.y-l1begin.y)*(l1end.x-l1begin.x))/D;
    _t2:=((l2begin.y-l1begin.y)*(l2begin.x-l2end.x)-(l2begin.y-l2end.y)*(l2begin.x-l1begin.x))/D;
    //if ((t1 <= 1) and (t1 >= 0) and (t2 >= 0) and (t2 <= 1)) then
    begin
      with TzePoint2d((@l1begin)^) do begin
        Result.interceptcoord:=TzePoint2d.Make(x+(l1end.x-x)*_t2,y+(l1end.y-y)*_t2);
        {result.interceptcoord.x := x + (l1end.x - x) * _t2;
        result.interceptcoord.y := y + (l1end.y - y) * _t2;}
      end;
      //if abs(result.interceptcoord.z-z)<eps then
      begin
        with intercept2dprop((@Result)^) do begin
          t1:=_t2;
          t2:=_t1;
          isintercept:=true;
        end;
      end;
    end;
  end;
end;

function intercept3dmy(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;
var
  z,_t1,_t2,d:double;
begin
  Result.isintercept:=false;
  D:=(l1end.y-l1begin.y)*(l2begin.x-l2end.x)-(l2begin.y-l2end.y)*(l1end.x-l1begin.x);
  if (D<>0) then begin
    _t1:=((l1end.y-l1begin.y)*(l2begin.x-l1begin.x)-(l2begin.y-l1begin.y)*(l1end.x-l1begin.x))/D;
    _t2:=((l2begin.y-l1begin.y)*(l2begin.x-l2end.x)-(l2begin.y-l2end.y)*(l2begin.x-l1begin.x))/D;
    if ((_t1<=1) and (_t1>=0) and (_t2>=0) and (_t2<=1)) then begin
      with TzePoint3d((@l1begin)^) do begin
        Result.interceptcoord:=TzePoint3d.Make(x+(l1end.x-x)*_t2,y+(l1end.y-y)*_t2,z+(l1end.z-z)*_t2);
      end;
      z:=l2begin.z+(l2end.z-l2begin.z)*_t1;
      if abs(Result.interceptcoord.z-z)<eps then begin
        with intercept3dprop((@Result)^) do begin
          t1:=_t2;
          t2:=_t1;
          isintercept:=true;
        end;
      end;
    end;
  end;
end;

function intercept3dmy2(const l1begin,l1end,l2begin,l2end:TzePoint3d):intercept3dprop;
var
  p13,p43,p21:TzePoint3d;
  d1343,d4321,d1321,d4343,d2121,numer,denom:double;
begin
  Result.isintercept:=false;
  p13.x:=l1begin.x-l2begin.x;
  p13.y:=l1begin.y-l2begin.y;
  p13.z:=l1begin.z-l2begin.z;
  p43.x:=l2end.x-l2begin.x;
  p43.y:=l2end.y-l2begin.y;
  p43.z:=l2end.z-l2begin.z;
  if (ABS(p43.x)<EPS) and (ABS(p43.y)<EPS) and (ABS(p43.z)<EPS) then
    exit;

  p21.x:=l1end.x-l1begin.x;
  p21.y:=l1end.y-l1begin.y;
  p21.z:=l1end.z-l1begin.z;
  if (ABS(p21.x)<EPS) and (ABS(p21.y)<EPS) and (ABS(p21.z)<EPS) then
    exit;

  d1343:=p13.x*p43.x+p13.y*p43.y+p13.z*p43.z;
  d4321:=p43.x*p21.x+p43.y*p21.y+p43.z*p21.z;
  d1321:=p13.x*p21.x+p13.y*p21.y+p13.z*p21.z;
  d4343:=p43.x*p43.x+p43.y*p43.y+p43.z*p43.z;
  d2121:=p21.x*p21.x+p21.y*p21.y+p21.z*p21.z;

  denom:=d2121*d4343-d4321*d4321;
  if (ABS(denom)<bigEPS) then
    exit;
  numer:=d1343*d4321-d1321*d4343;

  Result.t1:=numer/denom;
  Result.t2:=(d1343+d4321*Result.t1)/d4343;
  Result.interceptcoord:=TzePoint3d.Make(l1begin.x+Result.t1*p21.x,l1begin.y+Result.t1*p21.y,l1begin.z+Result.t1*p21.z);
  Result.isintercept:=true;
end;

begin
end.

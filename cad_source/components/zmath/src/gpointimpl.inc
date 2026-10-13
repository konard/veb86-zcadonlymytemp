function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.SqrLength:Double;
begin
  {$IfDef HAS_X}result:=sqr({$if FPC_FULLVERSION<30205}T(x){$else}x{$endif});{$Else}result:=0;{$EndIf}
  {$IfDef HAS_Y}result:=result+sqr({$if FPC_FULLVERSION<30205}T(y){$else}y{$endif});{$EndIf}
  {$IfDef HAS_Z}result:=result+sqr({$if FPC_FULLVERSION<30205}T(z){$else}z{$endif});{$EndIf}
  {$IfDef HAS_W}result:=result+sqr({$if FPC_FULLVERSION<30205}T(w){$else}w{$endif});{$EndIf}
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Length:Double;
begin
  //result:=norm(v);
  result:=Sqrt(SqrLength);
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.SqrLengthTo(const APt2:TSelf):Double;inline;
begin
  {$IfDef HAS_X}result:=sqr(APt2.x-x);{$Else}result:=0;{$EndIf}
  {$IfDef HAS_Y}result:=result+sqr(APt2.y-y);{$EndIf}
  {$IfDef HAS_Z}result:=result+sqr(APt2.z-z);{$EndIf}
  {$IfDef HAS_W}result:=result+sqr(APt2.w-w);{$EndIf}
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.LengthTo(const APt2:TSelf):Double;inline;
begin
  result:=Sqrt(SqrLengthTo(APt2));
end;

{$IfNDef IntParam}
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Normalized:TSelf;
  procedure dbz;
  begin
    zDebugLn('{EH}'+rsDivByZero);
  end;
var
  len:Double;
begin
  len:=Length;
  if abs(len)>eps then begin
    {$IfDef HAS_X}result.x:=x/len;{$EndIf}
    {$IfDef HAS_Y}result.y:=y/len;{$EndIf}
    {$IfDef HAS_Z}result.z:=z/len;{$EndIf}
    {$IfDef HAS_W}result.w:=w/len;{$EndIf}
  end else
    dbz;
end;
procedure PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Normalize;inline;
  procedure dbz;
  begin
    zDebugLn('{EH}'+rsDivByZero);
  end;
var
  len:Double;
begin
  len:=Length;
  if abs(len)>eps then begin
    {$IfDef HAS_X}x:=x/len;{$EndIf}
    {$IfDef HAS_Y}y:=y/len;{$EndIf}
    {$IfDef HAS_Z}z:=z/len;{$EndIf}
    {$IfDef HAS_W}w:=w/len;{$EndIf}
  end else begin
    dbz;
  end;
end;
procedure PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.EWAbs;
begin
{$IfDef HAS_X}x:={$if FPC_FULLVERSION<30205}x*sign(T(x));{$else}Abs(x);{$EndIf}{$endif}
{$IfDef HAS_Y}y:={$if FPC_FULLVERSION<30205}y*sign(T(y));{$else}Abs(y);{$EndIf}{$endif}
{$IfDef HAS_Z}z:={$if FPC_FULLVERSION<30205}z*sign(T(z));{$else}Abs(z);{$EndIf}{$endif}
{$IfDef HAS_W}w:={$if FPC_FULLVERSION<30205}w*sign(T(w));{$else}Abs(w);{$EndIf}{$endif}
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.EWAbsed:TSelf;
begin
  result:=self;
  result.EWAbs;
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.MulOnSc(const ASc:double):TSelf;
begin
  {$IfDef HAS_X}result.x:=x*ASc;{$EndIf}
  {$IfDef HAS_Y}result.y:=y*ASc;{$EndIf}
  {$IfDef HAS_Z}result.z:=z*ASc;{$EndIf}
  {$IfDef HAS_W}result.w:=w*ASc;{$EndIf}
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.LerpTo(const APt2:TSelf;const a:double):TSelf;
begin
  result:=self.Add(APt2.Sub(self).MulOnSC(a));
end;
{$EndIf}
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.IsEqual(const APt2:TSelf;const ASqrEps:Double=sqreps):boolean;
begin
  Result:=SqrLengthTo(APt2)<ASqrEps;
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.IsEqualEW(const APt2:TSelf;const AEps:Double=eps):boolean;inline;//element-wise compare
begin
  result:=(APt2-self.asVector).IsNulEW(AEps);
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.IsTrueEqual(const APt2:TSelf):boolean;inline;
begin
  result:=
  {$IfDef HAS_X}(x=APt2.x){$EndIf}
  {$IfDef HAS_Y}and(y=APt2.y){$EndIf}
  {$IfDef HAS_Z}and(z=APt2.z){$EndIf}
  {$IfDef HAS_W}and(w=APt2.w){$EndIf}
  ;
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.IsNul(const ASqrEps:Double=sqreps):boolean;
begin
  Result:=SqrLength<ASqrEps;
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.IsNulEW(const AEps:Double=sqreps):boolean;
begin
  result:=
  {$IfDef HAS_X}    ({$if FPC_FULLVERSION<30205}x*sign(T(x)){$else}Abs(x){$EndIf}<AEps){$EndIf}
  {$IfDef HAS_Y}and ({$if FPC_FULLVERSION<30205}y*sign(T(y)){$else}Abs(y){$EndIf}<AEps){$EndIf}
  {$IfDef HAS_Z}and ({$if FPC_FULLVERSION<30205}z*sign(T(z)){$else}Abs(z){$EndIf}<AEps){$EndIf}
  {$IfDef HAS_W}and ({$if FPC_FULLVERSION<30205}w*sign(T(w)){$else}Abs(w){$EndIf}<AEps){$EndIf}
  ;
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.IsBiggerEW(const AValue:Double=sqreps):boolean;
begin
  result:=
  {$IfDef HAS_X}    (x>AValue){$EndIf}
  {$IfDef HAS_Y}and (y>AValue){$EndIf}
  {$IfDef HAS_Z}and (z>AValue){$EndIf}
  {$IfDef HAS_W}and (w>AValue){$EndIf}
  ;
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Add(const APt2:TSelf):TSelf;
begin
  {$IfDef HAS_X}result.x:=x+APt2.x;{$EndIf}
  {$IfDef HAS_Y}result.y:=y+APt2.y;{$EndIf}
  {$IfDef HAS_Z}result.z:=z+APt2.z;{$EndIf}
  {$IfDef HAS_W}result.w:=w+APt2.w;{$EndIf}
end;
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Sub(const APt2:TSelf):TSelf;
begin
  {$IfDef HAS_X}result.x:=x-APt2.x;{$EndIf}
  {$IfDef HAS_Y}result.y:=y-APt2.y;{$EndIf}
  {$IfDef HAS_Z}result.z:=z-APt2.z;{$EndIf}
  {$IfDef HAS_W}result.w:=w-APt2.w;{$EndIf}
end;
(*class operator PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName>.+(const l,r:TSelf):TSelf;
var
  i:integer;
begin
  for i:=0 to ArrH do begin
    result.v[i]:=l.v[i]+r.v[i];
  end;
end;*)
class operator PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.+(const l:TSelf;r:GVectorTypeName):TSelf;inline;overload;
begin
  {$IfDef HAS_X}result.x:=l.x+{$if FPC_FULLVERSION<30205}TSelf{$endif}(r).x;{$EndIf}
  {$IfDef HAS_Y}result.y:=l.y+{$if FPC_FULLVERSION<30205}TSelf{$endif}(r).y;{$EndIf}
  {$IfDef HAS_Z}result.z:=l.z+{$if FPC_FULLVERSION<30205}TSelf{$endif}(r).z;{$EndIf}
  {$IfDef HAS_W}result.w:=l.w+{$if FPC_FULLVERSION<30205}TSelf{$endif}(r).w;{$EndIf}
end;
class operator PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.-(const l,r:TSelf):GVectorTypeName;
begin
  {$IfDef HAS_X}{$if FPC_FULLVERSION<30205}TSelf{$endif}(result).x:=l.x-r.x;{$EndIf}
  {$IfDef HAS_Y}{$if FPC_FULLVERSION<30205}TSelf{$endif}(result).y:=l.y-r.y;{$EndIf}
  {$IfDef HAS_Z}{$if FPC_FULLVERSION<30205}TSelf{$endif}(result).z:=l.z-r.z;{$EndIf}
  {$IfDef HAS_W}{$if FPC_FULLVERSION<30205}TSelf{$endif}(result).w:=l.w-r.w;{$EndIf}
end;
class operator PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.-(const l:TSelf;r:GVectorTypeName):TSelf;inline;overload;
var
  i:integer;
begin
  for i:=0 to ArrH do begin
    result.v[i]:=l.v[i]-{$if FPC_FULLVERSION<30205}TSelf{$endif}(r).v[i];
  end;
end;
class operator PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.-(const r:TSelf):TSelf;
begin
  {$IfDef HAS_X}result.x:=-r.x;{$EndIf}
  {$IfDef HAS_Y}result.y:=-r.y;{$EndIf}
  {$IfDef HAS_Z}result.z:=-r.z;{$EndIf}
  {$IfDef HAS_W}result.w:=-r.w;{$EndIf}
end;
class operator PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.*(const l:TSelf;const r:T):TSelf;
begin
  {$IfDef HAS_X}result.x:=l.x*r;{$EndIf}
  {$IfDef HAS_Y}result.y:=l.y*r;{$EndIf}
  {$IfDef HAS_Z}result.z:=l.z*r;{$EndIf}
  {$IfDef HAS_W}result.w:=l.w*r;{$EndIf}
end;
class operator PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.*(const l,r:TSelf):Real;
begin
  {$IfDef HAS_X}result:=l.x*r.x;{$else}result:=0{$EndIf}
  {$IfDef HAS_Y}result:=result+l.y*r.y;{$EndIf}
  {$IfDef HAS_Z}result:=result+l.z*r.z;{$EndIf}
  {$IfDef HAS_W}result:=result+l.w*r.w;{$EndIf}
end;
{$IfNDef IntParam}
class operator PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>./(const l:TSelf;const r:Real):TSelf;
begin
  {$IfDef HAS_X}result.x:=l.x/r;{$EndIf}
  {$IfDef HAS_Y}result.y:=l.y/r;{$EndIf}
  {$IfDef HAS_Z}result.z:=l.z/r;{$EndIf}
  {$IfDef HAS_W}result.w:=l.w/r;{$EndIf}
end;
{$EndIf}

constructor PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Make(const AData:TCoordArray);
begin
  v:=AData;
end;

procedure PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.setup(const AData:TCoordArray);inline;
begin
  v:=AData;
end;

constructor PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Make(const {$IfDef HAS_X}AX{$EndIf}{$IfDef HAS_Y},AY{$EndIf}{$IfDef HAS_Z},AZ{$EndIf}{$IfDef HAS_W},AW{$EndIf}:TCoordType);overload;
begin
  {$IfDef HAS_X}x:=AX;{$EndIf}
  {$IfDef HAS_Y}y:=AY;{$EndIf}
  {$IfDef HAS_Z}z:=AZ;{$EndIf}
  {$IfDef HAS_W}w:=AW;{$EndIf}
end;

constructor PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Fill(const AValue:TCoordType);overload;
begin
  {$IfDef HAS_X}x:=AValue;{$EndIf}
  {$IfDef HAS_Y}y:=AValue;{$EndIf}
  {$IfDef HAS_Z}z:=AValue;{$EndIf}
  {$IfDef HAS_W}w:=AValue;{$EndIf}
end;

procedure PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.setup(const {$IfDef HAS_X}AX{$EndIf}{$IfDef HAS_Y},AY{$EndIf}{$IfDef HAS_Z},AZ{$EndIf}{$IfDef HAS_W},AW{$EndIf}:TCoordType);overload;
begin
  {$IfDef HAS_X}x:=AX;{$EndIf}
  {$IfDef HAS_Y}y:=AY;{$EndIf}
  {$IfDef HAS_Z}z:=AZ;{$EndIf}
  {$IfDef HAS_W}w:=AW;{$EndIf}
end;

procedure PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.setup(const ASlice:TSlice;const ACutOff:TCoordType);
begin
  Slice:=ASlice;
  CutOff:=ACutOff;
end;

{$If defined(HAS_Y) and (not defined(HAS_Z))}
function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Turned90R:TSelf;
begin
 result.x:=y;
 result.y:=-x;
end;

function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Turned90L:TSelf;
begin
 result.x:=-y;
 result.y:=x;
end;

procedure PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Turn90R;
var
  tmp:T;
begin
  tmp:=y;
  y:=-x;
  x:=tmp;
end;

procedure PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.Turn90L;
var
  tmp:T;
begin
  tmp:=y;
  y:=x;
  x:=-tmp;
end;
{$EndIf}

procedure PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.ConcatFromMinSide(const AValue:TSelf);
begin
{$IfDef HAS_X}
  if x>AValue.x then
    x:=AValue.x;
{$EndIf}
{$IfDef HAS_Y}
  if y>AValue.y then
    y:=AValue.y;
{$EndIf}
{$IfDef HAS_Z}
  if z>AValue.z then
    z:=AValue.z;
{$EndIf}
{$IfDef HAS_W}
  if w>AValue.w then
    w:=AValue.w;
{$EndIf}
end;

procedure PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.ConcatFromMaxSide(const AValue:TSelf);
begin
{$IfDef HAS_X}
  if x<AValue.x then
    x:=AValue.x;
{$EndIf}
{$IfDef HAS_Y}
  if y<AValue.y then
    y:=AValue.y;
{$EndIf}
{$IfDef HAS_Z}
  if z<AValue.z then
    z:=AValue.z;
{$EndIf}
{$IfDef HAS_W}
  if w<AValue.w then
    w:=AValue.w;
{$EndIf}
 end;

function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.LessOrEqual(const AValue:TSelf):boolean;
begin
  Result:=
{$IfDef HAS_X}
  (x<=AValue.x+eps)
{$EndIf}
{$IfDef HAS_Y}
  and(y<=AValue.y+eps)
{$EndIf}
{$IfDef HAS_Z}
  and(z<=AValue.z+eps)
{$EndIf}
{$IfDef HAS_W}
  and(w<=AValue.w+eps)
{$EndIf}
  ;
end;

function PointTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record;{$else},GSlice,{$endif}GVectorTypeName{$if FPC_FULLVERSION<30205}:record{$endif}>.GreaterOrEqual(const AValue:TSelf):boolean;
begin
  Result:=
{$IfDef HAS_X}
  (x>=AValue.x-eps)
{$EndIf}
{$IfDef HAS_Y}
  and(y>=AValue.y-eps)
{$EndIf}
{$IfDef HAS_Z}
  and(z>=AValue.z-eps)
{$EndIf}
{$IfDef HAS_W}
  and(w>=AValue.w-eps)
{$EndIf}
  ;
end;


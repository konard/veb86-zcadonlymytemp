function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.SqrLength:Double;
begin
  {$IfDef HAS_X}result:=sqr({$if FPC_FULLVERSION<30205}T(x){$else}x{$endif});{$Else}result:=0;{$EndIf}
  {$IfDef HAS_Y}result:=result+sqr({$if FPC_FULLVERSION<30205}T(y){$else}y{$endif});{$EndIf}
  {$IfDef HAS_Z}result:=result+sqr({$if FPC_FULLVERSION<30205}T(z){$else}z{$endif});{$EndIf}
  {$IfDef HAS_W}result:=result+sqr({$if FPC_FULLVERSION<30205}T(w){$else}w{$endif});{$EndIf}
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Length:Double;
begin
  //result:=norm(v);
  result:=Sqrt(SqrLength);
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.SqrLengthTo(const AVector2:TSelf):Double;inline;
begin
  {$IfDef HAS_X}result:=sqr(AVector2.x-x);{$Else}result:=0;{$EndIf}
  {$IfDef HAS_Y}result:=result+sqr(AVector2.y-y);{$EndIf}
  {$IfDef HAS_Z}result:=result+sqr(AVector2.z-z);{$EndIf}
  {$IfDef HAS_W}result:=result+sqr(AVector2.w-w);{$EndIf}
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.LengthTo(const AVector2:TSelf):Double;inline;
begin
  result:=Sqrt(SqrLengthTo(AVector2));
end;

{$IfNDef IntParam}
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Normalized:TSelf;
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
procedure VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Normalize;inline;
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
    //DebugLn('{EH}'+rsDivByZero);
    //len:=len+2;
  end;
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.DeHomogenized:TSlice;
begin
  if abs({$if FPC_FULLVERSION<30205}T(CutOff){$else}CutOff{$endif})>eps then begin
    result:=Slice/CutOff;
  end else
    result:=Slice;
end;

procedure VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.DeHomogenize;
var
  i:integer;
begin
  if abs(v[High(TCoordArray)])>eps then begin
    for i:=Low(TCoordArray) to High(TCoordArray)-1 do begin
      v[i]:=v[i]/v[High(TCoordArray)];
    end;
    v[High(TCoordArray)]:=1;
  end;
end;

procedure VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.EWAbs;
begin
  {$IfDef HAS_X}x:={$if FPC_FULLVERSION<30205}x*sign(T(x));{$else}Abs(x);{$EndIf}{$endif}
  {$IfDef HAS_Y}y:={$if FPC_FULLVERSION<30205}y*sign(T(y));{$else}Abs(y);{$EndIf}{$endif}
  {$IfDef HAS_Z}z:={$if FPC_FULLVERSION<30205}z*sign(T(z));{$else}Abs(z);{$EndIf}{$endif}
  {$IfDef HAS_W}w:={$if FPC_FULLVERSION<30205}w*sign(T(w));{$else}Abs(w);{$EndIf}{$endif}
end;

function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.EWAbsed:TSelf;
begin
  result:=self;
  result.EWAbs;
end;

function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.MulOnSc(const ASc:double):TSelf;
begin
  {$IfDef HAS_X}result.x:=x*ASc;{$EndIf}
  {$IfDef HAS_Y}result.y:=y*ASc;{$EndIf}
  {$IfDef HAS_Z}result.z:=z*ASc;{$EndIf}
  {$IfDef HAS_W}result.w:=w*ASc;{$EndIf}
end;

function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.LerpTo(const AVector2:TSelf;const a:double):TSelf;
begin
  result:=self.Add(AVector2.Sub(self).MulOnSC(a));
end;

function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.WithLength(const ALength:Double):TSelf;
var
  l:double;
begin
  l:=Length;
  if l>eps then
    result:=self*(ALength/Length)
  else
    result:=self;
end;


{$EndIf}
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.IsEqual(const AVector2:TSelf;const ASqrEps:Double=sqreps):boolean;
begin
  Result:=SqrLengthTo(AVector2)<ASqrEps;
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.IsEqualEW(const AVector2:TSelf;const AEps:Double=eps):boolean;inline;//element-wise compare
begin
  result:=(AVector2-self).IsNulEW(AEps);
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.IsTrueEqual(const AVector2:TSelf):boolean;inline;
begin
  result:=
  {$IfDef HAS_X}(x=AVector2.x){$EndIf}
  {$IfDef HAS_Y}and(y=AVector2.y){$EndIf}
  {$IfDef HAS_Z}and(z=AVector2.z){$EndIf}
  {$IfDef HAS_W}and(w=AVector2.w){$EndIf}
  ;
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.IsNul(const ASqrEps:Double=sqreps):boolean;
begin
  Result:=SqrLength<ASqrEps;
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.IsNulEW(const AEps:Double=sqreps):boolean;
begin
  result:=
  {$IfDef HAS_X}    ({$if FPC_FULLVERSION<30205}x*sign(T(x)){$else}Abs(x){$EndIf}<AEps){$EndIf}
  {$IfDef HAS_Y}and ({$if FPC_FULLVERSION<30205}y*sign(T(y)){$else}Abs(y){$EndIf}<AEps){$EndIf}
  {$IfDef HAS_Z}and ({$if FPC_FULLVERSION<30205}z*sign(T(z)){$else}Abs(z){$EndIf}<AEps){$EndIf}
  {$IfDef HAS_W}and ({$if FPC_FULLVERSION<30205}w*sign(T(w)){$else}Abs(w){$EndIf}<AEps){$EndIf}
  ;
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.IsBiggerEW(const AValue:Double=sqreps):boolean;
begin
  result:=
  {$IfDef HAS_X}    (x>AValue){$EndIf}
  {$IfDef HAS_Y}and (y>AValue){$EndIf}
  {$IfDef HAS_Z}and (z>AValue){$EndIf}
  {$IfDef HAS_W}and (w>AValue){$EndIf}
  ;
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Add(const AVector2:TSelf):TSelf;
begin
  {$IfDef HAS_X}result.x:=x+AVector2.x;{$EndIf}
  {$IfDef HAS_Y}result.y:=y+AVector2.y;{$EndIf}
  {$IfDef HAS_Z}result.z:=z+AVector2.z;{$EndIf}
  {$IfDef HAS_W}result.w:=w+AVector2.w;{$EndIf}
end;
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Sub(const AVector2:TSelf):TSelf;
begin
  {$IfDef HAS_X}result.x:=x-AVector2.x;{$EndIf}
  {$IfDef HAS_Y}result.y:=y-AVector2.y;{$EndIf}
  {$IfDef HAS_Z}result.z:=z-AVector2.z;{$EndIf}
  {$IfDef HAS_W}result.w:=w-AVector2.w;{$EndIf}
end;
class operator VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.+(const l,r:TSelf):TSelf;
begin
  {$IfDef HAS_X}result.x:=l.x+r.x;{$EndIf}
  {$IfDef HAS_Y}result.y:=l.y+r.y;{$EndIf}
  {$IfDef HAS_Z}result.z:=l.z+r.z;{$EndIf}
  {$IfDef HAS_W}result.w:=l.w+r.w;{$EndIf}
end;
class operator VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.-(const l,r:TSelf):TSelf;
begin
  {$IfDef HAS_X}result.x:=l.x-r.x;{$EndIf}
  {$IfDef HAS_Y}result.y:=l.y-r.y;{$EndIf}
  {$IfDef HAS_Z}result.z:=l.z-r.z;{$EndIf}
  {$IfDef HAS_W}result.w:=l.w-r.w;{$EndIf}
end;
class operator VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.-(const r:TSelf):TSelf;
begin
  {$IfDef HAS_X}result.x:=-r.x;{$EndIf}
  {$IfDef HAS_Y}result.y:=-r.y;{$EndIf}
  {$IfDef HAS_Z}result.z:=-r.z;{$EndIf}
  {$IfDef HAS_W}result.w:=-r.w;{$EndIf}
end;
class operator VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.*(const l:TSelf;const r:T):TSelf;
begin
  {$IfDef HAS_X}result.x:=l.x*r;{$EndIf}
  {$IfDef HAS_Y}result.y:=l.y*r;{$EndIf}
  {$IfDef HAS_Z}result.z:=l.z*r;{$EndIf}
  {$IfDef HAS_W}result.w:=l.w*r;{$EndIf}
end;
class operator VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.*(const l,r:TSelf):Real;
begin
  {$IfDef HAS_X}result:=l.x*r.x;{$else}result:=0{$EndIf}
  {$IfDef HAS_Y}result:=result+l.y*r.y;{$EndIf}
  {$IfDef HAS_Z}result:=result+l.z*r.z;{$EndIf}
  {$IfDef HAS_W}result:=result+l.w*r.w;{$EndIf}
end;
{$IfNDef IntParam}
class operator VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>./(const l:TSelf;const r:Real):TSelf;
begin
  {$IfDef HAS_X}result.x:=l.x/r;{$EndIf}
  {$IfDef HAS_Y}result.y:=l.y/r;{$EndIf}
  {$IfDef HAS_Z}result.z:=l.z/r;{$EndIf}
  {$IfDef HAS_W}result.w:=l.w/r;{$EndIf}
end;
{$EndIf}

constructor VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Make(const AData:TCoordArray);
begin
  v:=AData;
end;

procedure VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.setup(const AData:TCoordArray);inline;
begin
  v:=AData;
end;

constructor VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Make(const {$IfDef HAS_X}AX{$EndIf}{$IfDef HAS_Y},AY{$EndIf}{$IfDef HAS_Z},AZ{$EndIf}{$IfDef HAS_W},AW{$EndIf}:TCoordType);overload;
begin
  {$IfDef HAS_X}x:=AX;{$EndIf}
  {$IfDef HAS_Y}y:=AY;{$EndIf}
  {$IfDef HAS_Z}z:=AZ;{$EndIf}
  {$IfDef HAS_W}w:=AW;{$EndIf}
end;

constructor VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Fill(const AValue:TCoordType);overload;
begin
  {$IfDef HAS_X}x:=AValue;{$EndIf}
  {$IfDef HAS_Y}y:=AValue;{$EndIf}
  {$IfDef HAS_Z}z:=AValue;{$EndIf}
  {$IfDef HAS_W}w:=AValue;{$EndIf}
end;

procedure VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.setup(const {$IfDef HAS_X}AX{$EndIf}{$IfDef HAS_Y},AY{$EndIf}{$IfDef HAS_Z},AZ{$EndIf}{$IfDef HAS_W},AW{$EndIf}:TCoordType);overload;
begin
  {$IfDef HAS_X}x:=AX;{$EndIf}
  {$IfDef HAS_Y}y:=AY;{$EndIf}
  {$IfDef HAS_Z}z:=AZ;{$EndIf}
  {$IfDef HAS_W}w:=AW;{$EndIf}
end;

{$If defined(HAS_Y) and (not defined(HAS_Z))}
function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Turned90R:TSelf;
begin
 result.x:=y;
 result.y:=-x;
end;

function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Turned90L:TSelf;
begin
 result.x:=-y;
 result.y:=x;
end;

procedure VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Turn90R;
var
  tmp:T;
begin
  tmp:=y;
  y:=-x;
  x:=tmp;
end;

procedure VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.Turn90L;
var
  tmp:T;
begin
  tmp:=y;
  y:=x;
  x:=-tmp;
end;
{$EndIf}

procedure VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.ConcatFromMinSide(const AValue:TSelf);
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

procedure VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.ConcatFromMaxSide(const AValue:TSelf);
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

function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.LessOrEqual(const AValue:TSelf):boolean;
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

function VectorTypeName<T{$if FPC_FULLVERSION<30205};GSlice:record;TT:record{$else},GSlice{$endif}>.GreaterOrEqual(const AValue:TSelf):boolean;
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


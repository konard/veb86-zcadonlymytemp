    const
      ArrS={$if defined(HAS_W)}4{$elseif defined(HAS_Z)}3{$elseif defined(HAS_Y)}2{$else}1{$endif};
    type
      TCoordType={$if FPC_FULLVERSION<30205}TT{$else}T{$endif};
      TCoordRec=record {$IfDef HAS_X}x{$EndIf}{$IfDef HAS_Y},y{$EndIf}{$IfDef HAS_Z},z{$EndIf}{$IfDef HAS_W},w{$EndIf}:TCoordType end;
      TCoordArray=array [0..ArrS-1] of T;
      TSelf=VectorTypeName<T{$if FPC_FULLVERSION<30205},GSlice,TT{$else},GSlice{$endif}>;
      TSlice=GSlice;
    const
      ArrH=High(TCoordArray);
      ArrL=Low(TCoordArray);

    function SqrLength:Double;inline;
    function Length:Double;inline;
    function SqrLengthTo(const AVector2:TSelf):Double;inline;
    function LengthTo(const AVector2:TSelf):Double;inline;
    {$IfNDef IntParam}
    function Normalized:TSelf;inline;
    procedure Normalize;inline;
    function DeHomogenized:TSlice;inline;
    procedure DeHomogenize;inline;
    procedure EWAbs;inline;//element-wise Abs
    function EWAbsed:TSelf;inline;//element-wise Abs
    function MulOnSc(const ASc:double):TSelf;inline;
    function LerpTo(const AVector2:TSelf;const a:double):TSelf;inline;
    function WithLength(const ALength:Double):TSelf;inline;
    {$EndIf}
    function IsEqual(const AVector2:TSelf;const ASqrEps:Double=sqreps):boolean;inline;
    function IsEqualEW(const AVector2:TSelf;const AEps:Double=eps):boolean;inline;//element-wise compare
    function IsTrueEqual(const AVector2:TSelf):boolean;inline;
    function IsNul(const ASqrEps:Double=sqreps):boolean;inline;
    function IsNulEW(const AEps:Double=sqreps):boolean;inline;//element-wise compare
    function IsBiggerEW(const AValue:Double=sqreps):boolean;inline;//element-wise compare
    function Add(const AVector2:TSelf):TSelf;inline;
    function Sub(const AVector2:TSelf):TSelf;inline;

    class operator +(const l,r:TSelf):TSelf;inline;
    class operator -(const l,r:TSelf):TSelf;inline;overload;
    class operator -(const r:TSelf):TSelf;inline;overload;
    class operator *(const l:TSelf;const r:T):TSelf;inline;
    class operator *(const l,r:TSelf):Real;inline;
    {$IfNDef IntParam}
    class operator /(const l:TSelf;const r:Real):TSelf;inline;
    {$EndIf}
    procedure setup(const AData:TCoordArray);inline;
    constructor Make(const AData:TCoordArray);overload;
    constructor Make(const {$IfDef HAS_X}AX{$EndIf}{$IfDef HAS_Y},AY{$EndIf}
                             {$IfDef HAS_Z},AZ{$EndIf}{$IfDef HAS_W},AW{$EndIf}:TCoordType);overload;
    constructor Fill(const AValue:TCoordType);overload;
    procedure setup(const {$IfDef HAS_X}AX{$EndIf}{$IfDef HAS_Y},AY{$EndIf}
                         {$IfDef HAS_Z},AZ{$EndIf}{$IfDef HAS_W},AW{$EndIf}:TCoordType);overload;
    {$If defined(HAS_Y) and (not defined(HAS_Z))}
    function Turned90R:TSelf;inline;
    function Turned90L:TSelf;inline;
    procedure Turn90R;inline;
    procedure Turn90L;inline;
    {$EndIf}
    procedure ConcatFromMinSide(const AValue:TSelf);
    procedure ConcatFromMaxSide(const AValue:TSelf);
    function LessOrEqual(const AValue:TSelf):boolean;
    function GreaterOrEqual(const AValue:TSelf):boolean;
    var
      case Integer of
        0:({$IfDef HAS_X}x{$EndIf}{$IfDef HAS_Y},y{$EndIf}{$IfDef HAS_Z},z{$EndIf}{$IfDef HAS_W},w{$EndIf}:TCoordType);
        1:(v:TCoordArray);
        //2:(r:TCoordRec);
        3:(Slice:GSlice;CutOff:{$if FPC_FULLVERSION<30205}TT{$else}T{$endif});

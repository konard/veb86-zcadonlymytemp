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

unit uzbUnitsUtils;

interface

uses
  SysUtils,Math,
  uzbUnits;

function zeDimensionToString(const Value:double;const f:TzeUnitsFormat):string;
function zeDimensionToUnicodeString(const Value:double;
  const f:TzeUnitsFormat):unicodestring;
function zeNonDimensionToString(const Value:double;const f:TzeUnitsFormat):string;
function zeAngleDegToString(const Value:double;const f:TzeUnitsFormat):string;
function zeAngleToString(const Value:double;const f:TzeUnitsFormat):string;
function zeStringToAngle(const Value:string;const f:TzeUnitsFormat):double;
function zeTryStringToAngle(const s:string;out value:double;const f:TzeUnitsFormat):boolean;
function CreateDefaultUnitsFormat:TzeUnitsFormat;

implementation

const
  eps=1e-14;
  FromDegToRad=pi/180;
  FromDegToGrad=200/180;
  FromRadToDegrees=180/pi;
  FromRadToGradians=200/pi;
  Fractions:array [TUPrec] of integer=(1,2,4,8,16,32,64,128,256);
  FromRadTo:array [TAUnits] of double=
    (FromRadToDegrees,FromRadToDegrees,FromRadToGradians,1,FromRadToDegrees);
  FromDegTo:array [TAUnits] of double=(1,1,FromDegToGrad,FromDegToRad,1);
  FromDimDSepToChar:array [TDimDSep] of char=('.',',',' ');

var
  WorkingFormatSettings:TFormatSettings;

function CreateDefaultUnitsFormat:TzeUnitsFormat;
begin
  Result.abase:=0;
  Result.adir:=ADCounterClockwise;
  Result.aformat:=AUDecimalDegrees;
  Result.aprec:=UPrec2;
  Result.uformat:=LUDecimal;
  Result.uprec:=UPrec2;
  Result.umode:=UMWithSpaces;
  Result.DeciminalSeparator:=DDSDot;
  Result.RemoveTrailingZeros:=False;
end;

function MyFloatToStr0(const Value:double):string;
begin
  Result:=FloatToStrF(Value,ffFixed,0,0,WorkingFormatSettings);
end;

function MyFloatToStr(const Value:double;Prec:TUPrec;DS:TDimDSep;RTZ:boolean):string;
var
  Q:integer;
begin
  WorkingFormatSettings.DecimalSeparator:=fromDimDSepToChar[DS];
     {case DS of
          DDSDot:WorkingFormatSettings.DecimalSeparator:='.';
        DDSComma:WorkingFormatSettings.DecimalSeparator:=',';
        DDSSpace:WorkingFormatSettings.DecimalSeparator:=' ';
     end;}
  Result:=FloatToStrF(Value,ffFixed,0,Ord(Prec),WorkingFormatSettings);

  if (Prec<>UPrec0)and RTZ then begin
    { Remove trailing zeros }
    Q:=Length(Result);
    while (Q>0) and (Result[Q]='0') do
      Dec(Q);
    if Result[Q]=ansichar(WorkingFormatSettings.DecimalSeparator) then
      Dec(Q); { Remove trailing decimal point }
    if (Q=0) or ((Q=1) and (Result[1]='-')) then
      Result:='0'
    else
      SetLength(Result,Q);
  end;
end;

(*procedure rtz(var _value:String);
var
  Q:Integer;
begin
  { Remove trailing zeros }
  Q := Length(_value);
  while (Q > 0) and (_value[Q] = '0') do
    Dec(Q);
  if _value[Q] = FormatSettings.DecimalSeparator then
    Dec(Q); { Remove trailing decimal point }
  if (Q = 0) or ((Q=1) and (_value[1] = '-')) then
    _value := '0'
  else
    SetLength(_value,Q);
end;*)
function zeNonDimensionToString(const Value:double;const f:TzeUnitsFormat):string;
var
  ff:TzeUnitsFormat;
begin
  if f.uformat=LUDecimal then
    Result:=zeDimensionToString(Value,f)
  else begin
    ff:=f;
    ff.uformat:=LUDecimal;
    Result:=zeDimensionToString(Value,ff);
  end;
end;

function zeAngleToString(const Value:double;const f:TzeUnitsFormat):string;
type
  TSUDir=(TSUDirN,TSUDirS);
  TSUSubDir=(TSUDirE,TSUDirW);
var
  ff:TzeUnitsFormat;
  angle,superangle:double;
  deg,min,sec,sec2:double;
  stemp:integer;
  _min,_sec:integer;
  degs,mins,secs:string;
  subaprec:TUPrec;

  function GetAngleDegreesMinutesSeconds:string;
  var
    i:integer;
  begin
    case f.aprec of
      UPrec0:begin
        ff.uprec:=UPrec0;
        Result:=zeDimensionToString(angle,ff);
      end;
      UPrec1,UPrec2:begin
        deg:=floor(angle);
        min:=angle-deg;
        _min:={floor}round(60*min);
        if _min>59 then begin
          deg:=deg+1;
          _min:=0;
        end;
        //str(deg:0:0,degs);
        degs:=MyFloatToStr0(deg);
        mins:=IntToStr(_min);
        Result:=format('%s%s%s%s',[degs,'d',mins,'''']);
      end;
      else begin
        deg:=floor(angle);
        min:=angle-deg;
        _min:=floor(60*min);
        sec:=min-_min/60;
        sec:=sec*3600;
        if Ord(f.aprec)<Ord(UPrec5) then begin
          _sec:=
            {floor}round({60*60*}sec);
          subaprec:=UPrec0;
        end else begin
          subaprec:=
            TUPrec(Ord(f.aprec)-Ord(UPrec4));
          sec2:=sec;
          stemp:=60;
          for i:=
            0 to Ord(subaprec) do begin
            stemp:=stemp*10;
            sec2:=sec2*10;
          end;
          _sec:=round(sec2);
        end;
        if _sec>=stemp then begin
          _min:=_min+1;
          _sec:=0;
          sec:=0;
        end;
        if _min>59 then begin
          deg:=deg+1;
          _min:=0;
        end;
        degs:=MyFloatToStr0(deg);
        mins:=IntToStr(_min);
        secs:=MyFloatToStr(sec,subaprec,f.DeciminalSeparator,f.RemoveTrailingZeros);
        Result:=format('%s%s%s%s%s%s',[degs,'d',mins,'''',secs,'"']);
      end;
    end;
  end;

begin
  if f.adir=ADCounterClockwise then
    angle:=Value-f.abase*FromDegToRad
  else
    angle:=-Value+f.abase*FromDegToRad;
  if angle<0 then
    angle:=2*pi+angle;
  if abs(angle-2*pi)<eps then
    angle:=0;
  angle:=angle*fromradto[f.aformat];
  ff:=f;
  ff.RemoveTrailingZeros:=False;
  ff.uformat:=LUDecimal;
  if (f.aformat=AUDecimalDegrees) then begin
    ff.uprec:=f.aprec;
    Result:=zeDimensionToString(angle,ff);
  end else begin
    case f.aformat of
      AUDegreesMinutesSeconds:
        Result:=GetAngleDegreesMinutesSeconds;
      AUGradians,AURadians:begin
        ff.uprec:=f.aprec;
        Result:=
          zeDimensionToString(angle,ff);
        if f.aformat=AUGradians then
          Result:=
            format('%s%s',[Result,'g'])
        else
          Result:=
            format('%s%s',[Result,'r']);
      end;
      AUSurveyorsUnits:begin
        //SUDir:TSUDir;
        //SUSubDir:TSUSubDir;
        if abs(angle)<eps then
          Result:=
            'E'
        else if abs(angle-90)<eps then
          Result:=
            'N'
        else if abs(angle-180)<eps then
          Result:=
            'W'
        else if abs(angle-270)<eps then
          Result:=
            'S'
        else begin
          superangle:=angle;
          if superangle<90 then
          begin
            Result:=
              'N%sE';
            angle:=
              abs(90-superangle);
          end
          else if superangle<180 then begin
            Result:=
              'N%sW';
            angle:=
              abs(superangle-90);
          end
          else if superangle<270 then begin
            Result:=
              'S%sW';
            angle:=
              abs(270-superangle);
          end
          else if superangle<360 then begin
            Result:=
              'S%sE';
            angle:=
              abs(superangle-270);
          end;
          Result:=
            format(Result,[GetAngleDegreesMinutesSeconds]);
        end;
      end;
    end;
  end;
end;

function zeStringToAngle(const Value:string;const f:TzeUnitsFormat):double;
begin
  Result:=degtorad(StrToFloat(Value));
end;

function zeTryStringToAngle(const s:string;out value:double;const f:TzeUnitsFormat):boolean;
begin
  result:=TryStrToFloat(s,value);
  if result then
    value:=DegToRad(value)
  else
    value:=0;
end;

function zeAngleDegToString(const Value:double;const f:TzeUnitsFormat):string;
var
  ff:TzeUnitsFormat;
  angle:double;
begin
  {if f.adir=ADCounterClockwise then
                                   angle:=value
                               else
                                   angle:=-value;}
  if Value<0 then
    angle:=360+Value
  else
    angle:=Value;
  if abs(angle-360)<eps then
    angle:=0;
  angle:=angle*fromdegto[f.aformat];
  ff:=f;
  ff.RemoveTrailingZeros:=False;
  ff.uformat:=LUDecimal;
  ff.uprec:=f.aprec;
  Result:=zeDimensionToString(angle,ff);
end;

function zeDimensionToUnicodeString(const Value:double;
  const f:TzeUnitsFormat):unicodestring;
begin
  Result:=unicodestring(zeDimensionToString(Value,f));
end;

function zeDimensionToString(const Value:double;const f:TzeUnitsFormat):string;
var
  _ft,_dft:double;{1}
  absvalue,_in:double;{12*_ft}
  _fts,_ins,_dfts:string;
  divide:integer;
  simplifieduprec:TUPrec;
begin
  //result:='fuckoff';exit;
  //';;Pattern length %f'#13#10'%s';
  case f.uformat of
    LUScientific:begin
      Result:=FloatToStrF(Value,ffexponent,Ord(f.uprec)+1,2);
    end;
    LUDecimal:begin
      //str(value:0:ord(f.uprec),result);
      Result:=
        MyFloatToStr(Value,f.uprec,f.DeciminalSeparator,f.RemoveTrailingZeros);
                       {if f.uprec<>UPrec0 then
                                              rtz(result);}
    end;
    LUEngineering:begin
      absvalue:=abs(Value);
      _in:=floor(absvalue/12);
      _ft:=absvalue-12*_in;
      if _in<>0 then begin
        //str(_in:0:0,_ins);
        _ins:=MyFloatToStr0(_in);
        //rtz(_ins);
      end;
      //str(_ft:0:ord(f.uprec),_fts);
      _fts:=MyFloatToStr(_ft,f.uprec,f.DeciminalSeparator,
        f.RemoveTrailingZeros);
                       {if f.uprec<>UPrec0 then
                                              rtz(_fts);}
      if _in<>0 then begin
        if f.umode=UMWithSpaces then
          Result:=
            format('%s''-%s"',[_ins,_fts])
        else
          Result:=
            format('%s''%s"',[_ins,_fts]);
      end else
        Result:=format('%s"',[_fts]);
      if sign(Value)=-1 then
        Result:='-'+Result;
    end;
    LUArchitectural:begin
      simplifieduprec:=f.uprec;
      absvalue:=abs(Value);
      _in:=floor(absvalue/12);
      _ft:=absvalue-12*_in;
      _dft:=floor(_ft);
      _ft:=_ft-_dft;
      divide:=round(_ft*fractions[f.uprec]);
      if {divide=1}divide=fractions[f.uprec] then begin
        _dft:=_dft+1;
        divide:=0;
      end;
      if _in<>0 then begin
        //str(_in:0:0,_ins);
        _ins:=MyFloatToStr0(_in);
        //rtz(_ins);
      end;
      if _dft<>0 then begin
        //str(_dft:0:0,_dfts);
        _dfts:=MyFloatToStr0(_dft);
        //rtz(_dfts);
      end;
      if divide<>0 then begin
        while (divide and 1)=0 do begin
          divide:=divide shr 1;
          simplifieduprec:=pred(simplifieduprec);
        end;
        _fts:=
          IntToStr(divide)+'/'+IntToStr(fractions[simplifieduprec])+'"';
      end;
      if (_in=0)and(_dft=0)and(divide=0) then
        exit('0"')
      else if (_in<>0)and(_dft=0)and(divide=0) then
        Result:=format('%s''',[_ins])
      else if (_in=0)and(_dft<>0)and(divide=0) then
        Result:=format('%s"',[_dfts])
      else if (_in=0)and(_dft=0)and(divide<>0) then
        Result:=_fts
      else if (_in<>0)and(_dft<>0)and(divide=0) then begin
        if
        f.umode=UMWithSpaces then
          Result:=
            format('%s''-%s"',[_ins,_dfts])
        else
          Result:=
            format('%s''%s"',[_ins,_dfts]);
      end
      else if (_in<>0)and(_dft=0)and(divide<>0) then begin
        if
        f.umode=UMWithSpaces then
          Result:=
            format('%s''-0 %s',[_ins,_fts])
        else
          Result:=
            format('%s''0-%s',[_ins,_fts]);
      end
      else if (_in=0)and(_dft<>0)and(divide<>0) then begin
        if
        f.umode=UMWithSpaces then
          Result:=
            format('%s %s',[_dfts,_fts])
        else
          Result:=
            format('%s-%s',[_dfts,_fts]);
      end
      else if (_in<>0)and(_dft<>0)and(divide<>0) then begin
        if f.umode=UMWithSpaces then
          Result:=
            format('%s''-%s %s',[_ins,_dfts,_fts])
        else
          Result:=
            format('%s''%s-%s',[_ins,_dfts,_fts]);
      end;
      if sign(Value)=-1 then
        Result:='-'+Result;
    end;
    LUFractional:begin
      simplifieduprec:=f.uprec;
      absvalue:=abs(Value);
      _in:=floor(absvalue);
      _ft:=absvalue-_in;
      divide:=round(_ft*fractions[f.uprec]);
      if {divide=1}divide=fractions[f.uprec] then begin
        _in:=_in+1;
        divide:=0;
      end;
      if _in<>0 then begin
        //str(_in:0:0,_ins);
        _ins:=MyFloatToStr0(_in);
        //rtz(_ins);
      end;
      if divide<>0 then begin
        while (divide and 1)=0 do begin
          divide:=divide shr 1;
          simplifieduprec:=pred(simplifieduprec);
        end;
        _fts:=
          IntToStr(divide)+'/'+IntToStr(fractions[simplifieduprec]);
      end;
      if (_in=0)and(divide=0) then
        exit('0')
      else if (_in<>0)and(divide=0) then
        Result:=_ins
      else if (_in=0)and(divide<>0) then
        Result:=_fts
      else if (_in<>0)and(divide<>0) then
        if f.umode=UMWithSpaces then
          Result:=
            format('%s %s',[_ins,_fts])
        else
          Result:=
            format('%s-%s',[_ins,_fts]);
      if sign(Value)=-1 then
        Result:='-'+Result;

    end;
  end;
end;

initialization
  {$IFDEF DELPHI}WorkingFormatSettings:=FormatSettings;{$ENDIF}
  {$IFNDEF DELPHI}WorkingFormatSettings:=DefaultFormatSettings;{$ENDIF}
end.

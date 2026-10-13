program nodroundtrip;

// issue veb86/zcadonlymytemp#1 «Починка NOD»: стили таблиц
// (ACAD_TABLESTYLE) и стили мультивыносок (ACAD_MLEADERSTYLE) не
// загружались из acadsave2000.dxf / acadsave2007.dxf, а пересохранённые
// файлы не открывались повторно. Тест для каждого из файлов:
//
//  1. Загрузка: в чертеже есть все стили таблиц и мультивыносок из NOD
//     исходного файла (а не только созданные по умолчанию «Standard»),
//     ссылки MLEADERSTYLE на текстовый стиль/блоки разрешены в имена.
//  2. Сохранение в DXF 2007 и DXF 2000 (шаблоны savetemplate2007/2000).
//  3. Структура сохранённого файла: пары «код/значение», каждая секция
//     ровно один раз, в CLASSES только CLASS, классы TABLESTYLE,
//     CELLSTYLEMAP и MLEADERSTYLE объявлены, хэндлы уникальны, ссылки
//     330/350/360 (и ссылки 340/341/342/343 объектов стилей) указывают на
//     существующие объекты, $HANDSEED больше всех хэндлов, в NOD есть
//     ACAD_TABLESTYLE и (только DXF 2007+, MinVersion = AC1021 по ТЗ,
//     этап 6) ACAD_MLEADERSTYLE.
//  4. Повторная загрузка сохранённого файла: те же стили с теми же
//     разрешёнными ссылками (в DXF 2000 из стилей мультивыносок остаётся
//     только «Standard» по умолчанию).
//  5. Имена DXF до 2007 в кодовой странице $DWGCODEPAGE: «Аннотативный»
//     из acadsave2000.dxf (ANSI_1251) загружается в UTF-8, стиль таблиц с
//     кириллическим именем записывается в DXF 2000 в ANSI_1251 и читается
//     обратно.
//
// Использование:
//   nodroundtrip [<корень репозитория>]
// Сборка и запуск: cad_source/zengine/tests/nodtests.sh nodroundtrip

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, Interfaces,
  uzeffdxf, uzeffdxfout, uzedrawingsimple, uzeffmanager, uzeffdxfsupport,
  uzgldrawcontext, uzeconsts, uzeTypes,
  uzestylestablesdxf, uzestylesmleaderdxf;

const
  TemplatesDir = 'environment/runtimefiles/AllCPU-AllOS/common/cfg/components/';
  Template2007 = 'savetemplate2007.dxf';
  Template2000 = 'savetemplate2000.dxf';

  SourceFiles: array[0..1] of string = ('acadsave2000.dxf', 'acadsave2007.dxf');

  { Стили в NOD исходных файлов (сохранены AutoCAD) }
  ExpectedTableStyles: array[0..3] of string =
    ('Standard', 'table1', 'table2', 'table7');
  ExpectedMLeaderStyles: array[0..3] of string =
    ('Standard', 'multi1', 'multi7', 'Аннотативный');

var
  Root: string;
  Failed: Integer;

procedure Fail(const S: string);
begin
  writeln('FAIL: ', S);
  Inc(Failed);
end;

procedure Ok(const S: string);
begin
  writeln('ok:   ', S);
end;

procedure Check(ACondition: Boolean; const S: string);
begin
  if ACondition then
    Ok(S)
  else
    Fail(S);
end;

procedure CheckInt(AExpected, AActual: Int64; const S: string);
begin
  if AExpected = AActual then
    Ok(Format('%s = %d', [S, AActual]))
  else
    Fail(Format('%s: expected %d, got %d', [S, AExpected, AActual]));
end;

procedure CheckStr(const AExpected, AActual, S: string);
begin
  if AExpected = AActual then
    Ok(Format('%s = "%s"', [S, AActual]))
  else
    Fail(Format('%s: expected "%s", got "%s"', [S, AExpected, AActual]));
end;

{ ---------- Загрузка/сохранение ---------- }

{ Кодовая страница чертежа по системной кодовой странице $DWGCODEPAGE }
function SysCPToZCCodePage(ASysCP: Integer): TZCCodePage;
begin
  case ASysCP of
    874: Result := ZCCP874;
    932: Result := ZCCP932;
    936: Result := ZCCP936;
    949: Result := ZCCP949;
    950: Result := ZCCP950;
    1250: Result := ZCCP1250;
    1251: Result := ZCCP1251;
    1252: Result := ZCCP1252;
    1253: Result := ZCCP1253;
    1254: Result := ZCCP1254;
    1255: Result := ZCCP1255;
    1256: Result := ZCCP1256;
    1257: Result := ZCCP1257;
    1258: Result := ZCCP1258;
    else Result := sysvarSysDWG_CodePage;
  end;
end;

{ Загрузка DXF с установкой кодовой страницы чертежа из $DWGCODEPAGE —
  как LoadDXFviaZEnfine (cad_source/zcad/register/uzcregfileformats.pas) }
procedure LoadDrawing(const AFileName: string; var ADrawing: TSimpleDrawing);
var
  DC: TDrawContext;
  ZDC: TZDrawingContext;
  Hdr: TDXFHeaderInfo;
begin
  DC := ADrawing.CreateDrawingRC;
  ZDC.CreateRec(ADrawing, ADrawing.pObjRoot^, TLOLoad, DC);
  Hdr := AddFromDXF(AFileName, ZDC);
  if Hdr.DWGCodePage <> CP_INVALID then
    ADrawing.DXFCodePage := SysCPToZCCodePage(Hdr.iDWGCodePage)
  else
    ADrawing.DXFCodePage := sysvarSysDWG_CodePage;
end;

{ TSimpleDrawing.done не освобождает строковые поля }
procedure DoneDrawing(var ADrawing: TSimpleDrawing);
begin
  ADrawing.done;
  ADrawing.RawClassesSection := '';
  ADrawing.RawObjectsSection := '';
end;

{ ---------- Снимок загруженных стилей ---------- }

{ Строка на стиль: имя и разрешённые при загрузке ссылки. Сравнивается
  до и после пересохранения. }
procedure SnapshotStyles(var ADrawing: TSimpleDrawing; ATable, AMLeader: TStringList);
var
  I: Integer;
  PT: PTGDBDXFTableStyle;
  PM: PTGDBDXFMLeaderStyle;
begin
  ATable.Clear;
  AMLeader.Clear;
  for I := 0 to ADrawing.DXFTableStyleTable.Count - 1 do begin
    PT := ADrawing.DXFTableStyleTable.getDataMutable(I);
    ATable.Add(Format('%s|title=%s|header=%s|data=%s|cells=%d',
      [PT^.Name, PT^.CellTextStyleName[0], PT^.CellTextStyleName[1],
       PT^.CellTextStyleName[2], PT^.CellFormats.Count]));
  end;
  for I := 0 to ADrawing.DXFMLeaderStyleTable.Count - 1 do begin
    PM := ADrawing.DXFMLeaderStyleTable.getDataMutable(I);
    AMLeader.Add(Format('%s|text=%s|arrow=%s|block=%s|ltype=%s|content=%d',
      [PM^.Name, PM^.TextStyleName, PM^.ArrowHeadBlockName,
       PM^.BlockContentName, PM^.LeaderLinetypeName, PM^.ContentType]));
  end;
  ATable.Sort;
  AMLeader.Sort;
end;

function HasStyle(AList: TStrings; const AName: string): Boolean;
var
  I: Integer;
begin
  for I := 0 to AList.Count - 1 do
    if Copy(AList[I], 1, Length(AName) + 1) = AName + '|' then
      Exit(True);
  Result := False;
end;

function StyleLine(AList: TStrings; const AName: string): string;
var
  I: Integer;
begin
  for I := 0 to AList.Count - 1 do
    if Copy(AList[I], 1, Length(AName) + 1) = AName + '|' then
      Exit(AList[I]);
  Result := '';
end;

{ AAllMLeader = False — файл DXF 2000, сохранённый ZCAD: стилей
  мультивыносок в нём нет, после загрузки есть только «Standard» }
procedure CheckLoadedStyles(const ATitle: string; ATable, AMLeader: TStrings;
  AAllMLeader: Boolean = True);
var
  I: Integer;
begin
  CheckInt(Length(ExpectedTableStyles), ATable.Count,
    ATitle + ': table styles');
  for I := Low(ExpectedTableStyles) to High(ExpectedTableStyles) do
    Check(HasStyle(ATable, ExpectedTableStyles[I]),
      ATitle + ': table style ' + ExpectedTableStyles[I]);
  if AAllMLeader then begin
    CheckInt(Length(ExpectedMLeaderStyles), AMLeader.Count,
      ATitle + ': mleader styles');
    for I := Low(ExpectedMLeaderStyles) to High(ExpectedMLeaderStyles) do
      Check(HasStyle(AMLeader, ExpectedMLeaderStyles[I]),
        ATitle + ': mleader style ' + ExpectedMLeaderStyles[I]);
  end else
    CheckInt(1, AMLeader.Count, ATitle + ': mleader styles (only default)');
  { Ссылка 342 MLEADERSTYLE на текстовый стиль разрешена в имя }
  Check(Pos('|text=Standard|', StyleLine(AMLeader, 'Standard')) > 0,
    ATitle + ': mleader style Standard text style resolved');
end;

{ ---------- Структура сохранённого DXF ---------- }

type
  TDXFPair = record
    Code: Integer;
    Value: string;
  end;
  TDXFPairs = array of TDXFPair;

function ReadPairs(const AFileName: string; out APairs: TDXFPairs): Boolean;
var
  L: TStringList;
  I, N: Integer;
begin
  Result := True;
  L := TStringList.Create;
  try
    L.LoadFromFile(AFileName);
    if Odd(L.Count) then
      Result := False;
    SetLength(APairs, L.Count div 2);
    N := 0;
    I := 0;
    while I + 1 < L.Count do begin
      if not TryStrToInt(Trim(L[I]), APairs[N].Code) then begin
        writeln('  line ', I + 1, ': bad group code "', L[I], '"');
        Exit(False);
      end;
      APairs[N].Value := L[I + 1];
      Inc(N);
      Inc(I, 2);
    end;
    SetLength(APairs, N);
  finally
    L.Free;
  end;
end;

function IsPointerCode(ACode: Integer): Boolean;
begin
  Result := (ACode >= 330) and (ACode <= 369);
end;

procedure CheckSavedStructure(const AFileName: string; AExpectMLeader: Boolean);
const
  SectionNames: array[0..5] of string =
    ('HEADER', 'CLASSES', 'TABLES', 'BLOCKS', 'ENTITIES', 'OBJECTS');
  StyleClassNames: array[0..2] of string =
    ('TABLESTYLE', 'CELLSTYLEMAP', 'MLEADERSTYLE');
var
  P: TDXFPairs;
  I, J, Dup, Dangling, DanglingStyle, HandleCount: Integer;
  Section, ObjType, S, HandSeed: string;
  Sections, Classes, Handles, ObjTypes, NODKeys, Refs: TStringList;
  MaxHandle, H, Seed: QWord;
  NODHandle: string;
  InNOD, NonClassInClasses: Boolean;
  ObjectsInHeader, StyleObjectsOutside: Integer;
  Title: string;
begin
  Title := ExtractFileName(AFileName);
  if not ReadPairs(AFileName, P) then begin
    Fail(Title + ': file is a sequence of group code/value pairs');
    Exit;
  end;
  Ok(Title + ': file is a sequence of group code/value pairs');
  Sections := TStringList.Create;
  Classes := TStringList.Create;
  Handles := TStringList.Create;
  ObjTypes := TStringList.Create;
  NODKeys := TStringList.Create;
  Refs := TStringList.Create;
  try
    Handles.Sorted := True;
    Handles.Duplicates := dupAccept;
    Section := '';
    ObjType := '';
    MaxHandle := 0;
    HandSeed := '';
    NODHandle := '';
    InNOD := False;
    NonClassInClasses := False;
    ObjectsInHeader := 0;
    StyleObjectsOutside := 0;
    for I := 0 to High(P) do begin
      if P[I].Code = 0 then begin
        ObjType := Trim(P[I].Value);
        InNOD := False;
        if ObjType = 'ENDSEC' then
          Section := ''
        else if (Section = 'HEADER') then
          Inc(ObjectsInHeader)
        else if (Section <> 'OBJECTS') and ((ObjType = 'TABLESTYLE') or
                (ObjType = 'CELLSTYLEMAP') or (ObjType = 'MLEADERSTYLE')) then
          Inc(StyleObjectsOutside)
        else if (Section = 'CLASSES') and (ObjType <> 'CLASS') then
          NonClassInClasses := True
        else if Section = 'OBJECTS' then
          ObjTypes.Add(ObjType);
        Continue;
      end;
      if (ObjType = 'SECTION') and (P[I].Code = 2) then begin
        Section := Trim(P[I].Value);
        Sections.Add(Section);
        ObjType := '';
        Continue;
      end;
      if (Section = 'HEADER') and (P[I].Code = 9) and
         (Trim(P[I].Value) = '$HANDSEED') and (I < High(P)) then
        HandSeed := Trim(P[I + 1].Value);
      if (Section = 'CLASSES') and (ObjType = 'CLASS') and (P[I].Code = 1) then
        Classes.Add(Trim(P[I].Value));
      { Хэндл объекта: 5, у DIMSTYLE — 105 (в HEADER код 5 — значение
        переменной $HANDSEED, а не хэндл) }
      if (Section <> 'HEADER') and
         (((P[I].Code = 5) and (ObjType <> 'DIMSTYLE')) or
          ((P[I].Code = 105) and (ObjType = 'DIMSTYLE'))) then begin
        S := UpperCase(Trim(P[I].Value));
        Handles.Add(S);
        H := StrToQWord('$' + S);
        if H > MaxHandle then
          MaxHandle := H;
        { Первый словарь секции OBJECTS — NOD }
        if (Section = 'OBJECTS') and (ObjType = 'DICTIONARY') and
           (NODHandle = '') then begin
          NODHandle := S;
          InNOD := True;
        end;
      end;
      if InNOD and (P[I].Code = 3) then
        NODKeys.Add(P[I].Value);
      if IsPointerCode(P[I].Code) and (Trim(P[I].Value) <> '0') then
        Refs.Add(Format('%s|%d|%s', [ObjType, P[I].Code,
          UpperCase(Trim(P[I].Value))]));
    end;

    { Секции }
    for S in SectionNames do begin
      J := 0;
      for I := 0 to Sections.Count - 1 do
        if Sections[I] = S then
          Inc(J);
      CheckInt(1, J, Title + ': section ' + S + ' count');
    end;
    CheckInt(0, ObjectsInHeader, Title + ': object records inside HEADER section');
    CheckInt(0, StyleObjectsOutside, Title + ': style objects outside OBJECTS section');
    Check(not NonClassInClasses, Title + ': CLASSES section contains only CLASS records');

    { Классы объектов стилей объявлены (без них AutoCAD не открывает файл) }
    for S in StyleClassNames do
      if ObjTypes.IndexOf(S) >= 0 then
        Check(Classes.IndexOf(S) >= 0, Title + ': CLASS ' + S + ' declared');
    Classes.Sorted := True;
    Dup := 0;
    for I := 1 to Classes.Count - 1 do
      if Classes[I] = Classes[I - 1] then begin
        writeln('  duplicate CLASS ', Classes[I]);
        Inc(Dup);
      end;
    CheckInt(0, Dup, Title + ': duplicate CLASS records');

    { Хэндлы }
    HandleCount := Handles.Count;
    Dup := 0;
    for I := 1 to Handles.Count - 1 do
      if Handles[I] = Handles[I - 1] then begin
        if Dup < 10 then
          writeln('  duplicate handle ', Handles[I]);
        Inc(Dup);
      end;
    CheckInt(0, Dup, Title + Format(': duplicate handles (of %d)', [HandleCount]));
    Seed := 0;
    if HandSeed <> '' then
      Seed := StrToQWord('$' + HandSeed);
    Check(Seed > MaxHandle, Format('%s: $HANDSEED %s > max handle %s',
      [Title, HandSeed, IntToHex(MaxHandle, 0)]));

    { Ссылки }
    Dangling := 0;
    DanglingStyle := 0;
    for I := 0 to Refs.Count - 1 do begin
      S := Refs[I];
      J := LastDelimiter('|', S);
      if Handles.IndexOf(Copy(S, J + 1, MaxInt)) < 0 then begin
        if (Pos('|330|', S) > 0) or (Pos('|350|', S) > 0) or
           (Pos('|360|', S) > 0) then begin
          if Dangling < 10 then
            writeln('  dangling reference ', S);
          Inc(Dangling);
        end else if (Pos('TABLESTYLE|', S) = 1) or
                    (Pos('MLEADERSTYLE|', S) = 1) or
                    (Pos('CELLSTYLEMAP|', S) = 1) then begin
          writeln('  dangling style reference ', S, ' (empty value = unresolved handle)');
          Inc(DanglingStyle);
        end;
      end;
    end;
    CheckInt(0, Dangling, Title + ': dangling 330/350/360 references');
    CheckInt(0, DanglingStyle, Title + ': dangling references of style objects');

    { NOD }
    Check(NODHandle <> '', Title + ': NOD found');
    Check(NODKeys.IndexOf('ACAD_TABLESTYLE') >= 0, Title + ': NOD has ACAD_TABLESTYLE');
    if AExpectMLeader then
      Check(NODKeys.IndexOf('ACAD_MLEADERSTYLE') >= 0, Title + ': NOD has ACAD_MLEADERSTYLE')
    else
      Check(NODKeys.IndexOf('ACAD_MLEADERSTYLE') < 0,
        Title + ': NOD has no ACAD_MLEADERSTYLE (MinVersion AC1021)');
    for I := 1 to NODKeys.Count - 1 do
      if NODKeys[I] = NODKeys[I - 1] then
        Fail(Title + ': duplicate NOD key ' + NODKeys[I]);
  finally
    Refs.Free;
    NODKeys.Free;
    ObjTypes.Free;
    Handles.Free;
    Classes.Free;
    Sections.Free;
  end;
end;

{ ---------- Сценарий ---------- }

procedure RoundTrip(const ASource: string);
const
  Vers: array[0..1] of TZCDxfVersion = (ZCDxf2007, ZCDxf2000);
  VerNames: array[0..1] of string = ('2007', '2000');
  Templates: array[0..1] of string = (Template2007, Template2000);
  { Стили мультивыносок пишутся с DXF 2007 (ТЗ, этап 6) }
  WithMLeader: array[0..1] of Boolean = (True, False);
var
  Drawing, Reloaded: TSimpleDrawing;
  Table0, MLeader0, Table1, MLeader1: TStringList;
  I, K: Integer;
  OutFile, ExpectedMLeader: string;
begin
  writeln('--- ', ASource);
  Table0 := TStringList.Create;
  MLeader0 := TStringList.Create;
  Table1 := TStringList.Create;
  MLeader1 := TStringList.Create;
  try
    Drawing.init(nil);
    try
      LoadDrawing(Root + ASource, Drawing);
      SnapshotStyles(Drawing, Table0, MLeader0);
      for I := 0 to Table0.Count - 1 do
        writeln('  loaded table style   ', Table0[I]);
      for I := 0 to MLeader0.Count - 1 do
        writeln('  loaded mleader style ', MLeader0[I]);
      CheckLoadedStyles(ASource + ' loaded', Table0, MLeader0);

      for K := Low(Vers) to High(Vers) do begin
        OutFile := GetTempDir(False) + 'nodroundtrip_' +
          ChangeFileExt(ASource, '') + '_' + VerNames[K] + '.dxf';
        Check(savedxf20XX(OutFile, Root + TemplatesDir + Templates[K],
          Drawing, Vers[K]), ASource + ': saved as DXF ' + VerNames[K] +
          ' -> ' + OutFile);
        CheckSavedStructure(OutFile, WithMLeader[K]);

        Reloaded.init(nil);
        try
          LoadDrawing(OutFile, Reloaded);
          SnapshotStyles(Reloaded, Table1, MLeader1);
          CheckLoadedStyles(ExtractFileName(OutFile) + ' reloaded', Table1,
            MLeader1, WithMLeader[K]);
          CheckStr(Table0.Text, Table1.Text,
            ExtractFileName(OutFile) + ': table styles after round trip');
          if WithMLeader[K] then
            ExpectedMLeader := MLeader0.Text
          else
            ExpectedMLeader := StyleLine(MLeader0, 'Standard') + LineEnding;
          CheckStr(ExpectedMLeader, MLeader1.Text,
            ExtractFileName(OutFile) + ': mleader styles after round trip');
        finally
          DoneDrawing(Reloaded);
        end;
      end;
    finally
      DoneDrawing(Drawing);
    end;
  finally
    MLeader1.Free;
    Table1.Free;
    MLeader0.Free;
    Table0.Free;
  end;
end;

{ Кириллическое имя стиля таблиц в DXF 2000 (ANSI_1251): в файле — байты
  CP1251, а не UTF-8; после повторной загрузки — то же имя в UTF-8 }
procedure NonAsciiTableStyleRoundTrip;
const
  Source = 'acadsave2000.dxf';
  NewName = 'Таблица1';
var
  Drawing, Reloaded: TSimpleDrawing;
  PT: PTGDBDXFTableStyle;
  Table1, MLeader1: TStringList;
  OutFile: string;
  Data: TStringList;
  Raw, Cp1251Name: RawByteString;
begin
  writeln('--- ', Source, ': non-ASCII table style name in DXF 2000');
  OutFile := GetTempDir(False) + 'nodroundtrip_cp1251_2000.dxf';
  Drawing.init(nil);
  try
    LoadDrawing(Root + Source, Drawing);
    PT := Drawing.DXFTableStyleTable.getAddres(string('table1'));
    if PT = nil then begin
      Fail(Source + ': table style table1 not found');
      Exit;
    end;
    PT^.SetName(NewName);
    Check(savedxf20XX(OutFile, Root + TemplatesDir + Template2000,
      Drawing, ZCDxf2000), Source + ': saved as DXF 2000 -> ' + OutFile);
  finally
    DoneDrawing(Drawing);
  end;
  CheckSavedStructure(OutFile, False);

  Data := TStringList.Create;
  try
    Data.LoadFromFile(OutFile);
    Raw := Data.Text;
  finally
    Data.Free;
  end;
  Cp1251Name := NewName;
  SetCodePage(Cp1251Name, CP_UTF8, False);
  SetCodePage(Cp1251Name, 1251, True);
  SetCodePage(Raw, CP_NONE, False);
  SetCodePage(Cp1251Name, CP_NONE, False);
  Check(Pos(Cp1251Name, Raw) > 0, ExtractFileName(OutFile) +
    ': table style name is written in ANSI_1251');
  Check(Pos(RawByteString(NewName), Raw) = 0, ExtractFileName(OutFile) +
    ': table style name is not written in UTF-8');

  Table1 := TStringList.Create;
  MLeader1 := TStringList.Create;
  Reloaded.init(nil);
  try
    LoadDrawing(OutFile, Reloaded);
    SnapshotStyles(Reloaded, Table1, MLeader1);
    Check(HasStyle(Table1, NewName), ExtractFileName(OutFile) +
      ' reloaded: table style ' + NewName);
    Check(not HasStyle(Table1, 'table1'), ExtractFileName(OutFile) +
      ' reloaded: table style table1 is renamed');
  finally
    DoneDrawing(Reloaded);
    MLeader1.Free;
    Table1.Free;
  end;
end;

var
  I: Integer;
begin
  Root := '';
  if ParamCount > 0 then
    Root := IncludeTrailingPathDelimiter(ParamStr(1));
  Failed := 0;
  for I := Low(SourceFiles) to High(SourceFiles) do
    try
      RoundTrip(SourceFiles[I]);
    except
      on E: Exception do
        Fail(SourceFiles[I] + ': ' + E.ClassName + ': ' + E.Message);
    end;
  try
    NonAsciiTableStyleRoundTrip;
  except
    on E: Exception do
      Fail('non-ASCII table style: ' + E.ClassName + ': ' + E.Message);
  end;

  if Failed = 0 then
    writeln('OK')
  else begin
    writeln('FAILED: ', Failed);
    Halt(1);
  end;
end.

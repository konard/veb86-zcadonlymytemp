program nodroundtripmleadercreate;

// issue veb86/zcadonlymytemp#3 «Добавь окно менеджер стилей мультивыносок»:
// менеджер стилей мультивыносок (команды MLeaderStyles и
// MLeaderStyleManager) создаёт стиль «на основе» существующего через
// TGDBDXFMLeaderStyle.CopyPropertiesFrom и удаляет стиль через
// RemoveDataFromArray + Done + Freemem. Тест проверяет то же без GUI:
//
//  1. CopyPropertiesFrom копирует все параметры, кроме имени и хэндла
//     расширенного словаря; ExtraPairs — независимая копия.
//  2. Стиль «Копия из Аннотативный», созданный в чертеже из
//     acadsave2007.dxf на основе «Аннотативный», сохраняется в DXF 2007 и
//     после повторной загрузки имеет те же параметры, что и базовый стиль.
//  3. Удалённый стиль не попадает в сохранённый файл, остальные стили
//     сохраняются.
//
// Использование:
//   nodroundtripmleadercreate [<корень репозитория>]
// Сборка и запуск: cad_source/zengine/tests/nodtests.sh nodroundtripmleadercreate

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, Interfaces,
  uzeffdxf, uzeffdxfout, uzedrawingsimple, uzeffmanager, uzeffdxfsupport,
  uzgldrawcontext, uzeconsts, uzeTypes,
  uzestylesmleaderdxf;

const
  TemplatesDir = 'environment/runtimefiles/AllCPU-AllOS/common/cfg/components/';
  Template2007 = 'savetemplate2007.dxf';
  Source = 'acadsave2007.dxf';

  BaseName = 'Аннотативный';
  NewName = 'Копия из Аннотативный';
  DeletedName = 'multi1';

  { Стили в NOD acadsave2007.dxf (сохранён AutoCAD) }
  SourceStyles: array[0..3] of string =
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

{ Загрузка DXF 2007 (имена в UTF-8, кодовая страница не нужна) }
procedure LoadDrawing(const AFileName: string; var ADrawing: TSimpleDrawing);
var
  DC: TDrawContext;
  ZDC: TZDrawingContext;
begin
  DC := ADrawing.CreateDrawingRC;
  ZDC.CreateRec(ADrawing, ADrawing.pObjRoot^, TLOLoad, DC);
  AddFromDXF(AFileName, ZDC);
end;

{ TSimpleDrawing.done не освобождает строковые поля }
procedure DoneDrawing(var ADrawing: TSimpleDrawing);
begin
  ADrawing.done;
  ADrawing.RawClassesSection := '';
  ADrawing.RawObjectsSection := '';
end;

function Save2007(const AFileName: string; var ADrawing: TSimpleDrawing): Boolean;
begin
  Result := savedxf20XX(AFileName, Root + TemplatesDir + Template2007,
    ADrawing, ZCDxf2007);
end;

{ ---------- Параметры стиля ---------- }

{ Все параметры стиля, кроме имени и хэндла расширенного словаря.
  AWithHandles = False — без хэндлов ссылок: при сохранении хэндлы
  назначаются заново, ссылки сравниваются по разрешённым именам. }
function StyleProps(const AStyle: TGDBDXFMLeaderStyle;
  AWithHandles: Boolean): string;
var
  I: Integer;
begin
  with AStyle do begin
    Result := Format(
      'ltype=%d|lcolor=%d|ltypeid=%d|seg1c=%d|seg2c=%d|content=%d|' +
      'seg1=%g|seg2=%g|ltname=%s|attl=%d|attr=%d|tangle=%d|talign=%d|' +
      'tdir=%d|lweight=%d|dogleg=%s|doglen=%g|landing=%s|landgap=%g|' +
      'descr=%s|arrow=%s|th=%g|deftext=%s|text=%s|tcolor=%d|ahs=%g|' +
      'alwaysleft=%s|alignspace=%s|bscale=%g|block=%s|bcolor=%d|' +
      'bsx=%g|bsy=%g|overall=%g|annot=%s|break=%g|tdirneg=%s|' +
      'isblock=%s|ismtext=%s|bsz=%g|brot=%g|ver=%d',
      [LeaderLineType, LeaderLineColor, LeaderLineTypeId,
       FirstSegAngleConstraint, SecondSegAngleConstraint, ContentType,
       FirstSegAngle, SecondSegAngle, LeaderLinetypeName,
       TextAttachmentLeft, TextAttachmentRight, TextAngleType,
       TextAlignmentType, TextAttachmentDirection, LeaderLineWeight,
       BoolToStr(EnableDogleg, True), DoglegLength,
       BoolToStr(EnableLanding, True), LandingGap, Description,
       ArrowHeadBlockName, TextHeight, DefaultTextContent, TextStyleName,
       TextColor, ArrowHeadSize, BoolToStr(TextAlignAlwaysLeft, True),
       BoolToStr(AlignSpace, True), BlockContentScale, BlockContentName,
       BlockContentColor,
       BlockContentScaleX, BlockContentScaleY, OverallScale,
       BoolToStr(Annotative, True), BreakGapSize,
       BoolToStr(TextDirectionNegative, True),
       BoolToStr(IsBlockContent, True), BoolToStr(IsMTextContent, True),
       BlockContentScaleZ, BlockContentRotation, MLeaderVersion]);
    if AWithHandles then
      Result := Result + Format('|hltype=%s|harrow=%s|htext=%s|hblock=%s',
        [LeaderLinetypeHandle, ArrowHeadBlockHandle, TextStyleHandle,
         BlockContentHandle]);
    for I := 0 to High(ExtraPairs) do
      Result := Result + Format('|%d=%s',
        [ExtraPairs[I].Code, ExtraPairs[I].Value]);
  end;
end;

function FindStyle(var ADrawing: TSimpleDrawing;
  const AName: string): PTGDBDXFMLeaderStyle;
begin
  Result := ADrawing.DXFMLeaderStyleTable.getAddres(AName);
end;

{ Удаление как в менеджере стилей (uzcfmleaderstyles.DoStyleDelete) }
procedure DeleteStyle(var ADrawing: TSimpleDrawing; AStyle: PTGDBDXFMLeaderStyle);
begin
  ADrawing.DXFMLeaderStyleTable.RemoveDataFromArray(AStyle);
  AStyle^.Done;
  Freemem(Pointer(AStyle));
end;

{ ---------- Тесты ---------- }

{ 1. CopyPropertiesFrom на отдельных объектах }
procedure CopyPropertiesTest;
var
  A, B: TGDBDXFMLeaderStyle;
begin
  writeln('--- CopyPropertiesFrom');
  A.init('A');
  B.init('B');
  try
    { Значения, отличные от значений по умолчанию }
    A.LeaderLineType := 1;
    A.LeaderLineColor := 5;
    A.ContentType := 3;
    A.DoglegLength := 12.5;
    A.EnableDogleg := not B.EnableDogleg;
    A.Description := 'описание';
    A.ArrowHeadBlockName := '_DOT';
    A.ArrowHeadBlockHandle := '1F';
    A.TextStyleName := 'Annotative';
    A.TextStyleHandle := '2A';
    A.TextHeight := 7.25;
    A.ArrowHeadSize := 3.5;
    A.BlockContentName := 'Blk';
    A.BlockContentScaleZ := 2;
    A.IsMTextContent := not B.IsMTextContent;
    A.MLeaderVersion := 2;
    A.XDictHandle := 'ABC';
    SetLength(A.ExtraPairs, 1);
    A.ExtraPairs[0].Code := 300;
    A.ExtraPairs[0].Value := 'extra';

    Check(StyleProps(A, True) <> StyleProps(B, True),
      'source differs from a new style before copy');
    B.CopyPropertiesFrom(A);
    CheckStr(StyleProps(A, True), StyleProps(B, True),
      'all properties are copied');
    CheckStr('B', B.Name, 'name is kept');
    CheckStr('', B.XDictHandle, 'extension dictionary handle is not copied');
    CheckStr('ABC', A.XDictHandle, 'source extension dictionary handle');

    B.ExtraPairs[0].Value := 'changed';
    SetLength(B.ExtraPairs, 2);
    CheckStr('extra', A.ExtraPairs[0].Value,
      'source ExtraPairs value after changing the copy');
    CheckInt(1, Length(A.ExtraPairs),
      'source ExtraPairs length after changing the copy');
  finally
    B.Done;
    A.Done;
  end;
end;

{ 2-3. Создание стиля на основе существующего, удаление, сохранение }
procedure CreateDeleteRoundTrip;
var
  Drawing, Reloaded: TSimpleDrawing;
  PBase, PNew, PDel: PTGDBDXFMLeaderStyle;
  BaseProps, CreatedFile, DeletedFile: string;
  I, Count0: Integer;
begin
  writeln('--- ', Source, ': create "', NewName, '" based on "', BaseName, '"');
  CreatedFile := GetTempDir(False) + 'nodroundtripmleadercreate_created.dxf';
  DeletedFile := GetTempDir(False) + 'nodroundtripmleadercreate_deleted.dxf';

  { Создание стиля «на основе» и сохранение }
  Drawing.init(nil);
  try
    LoadDrawing(Root + Source, Drawing);
    Count0 := Drawing.DXFMLeaderStyleTable.Count;
    CheckInt(Length(SourceStyles), Count0, Source + ': mleader styles loaded');
    PBase := FindStyle(Drawing, BaseName);
    if PBase = nil then begin
      Fail(Source + ': base style ' + BaseName + ' not found');
      Exit;
    end;
    Check(PBase^.IsMTextContent, BaseName + ' is annotative (code 296)');
    BaseProps := StyleProps(PBase^, False);
    writeln('  base style ', BaseName, ': ', BaseProps);

    Check(FindStyle(Drawing, NewName) = nil, NewName + ' does not exist yet');
    PNew := Drawing.DXFMLeaderStyleTable.AddStyle(NewName);
    Check(PNew <> nil, 'AddStyle(' + NewName + ')');
    if PNew = nil then
      Exit;
    Check(StyleProps(PNew^, True) <> StyleProps(PBase^, True),
      'new style differs from the base style before copy');
    PNew^.CopyPropertiesFrom(PBase^);
    CheckStr(StyleProps(PBase^, True), StyleProps(PNew^, True),
      NewName + ': properties copied from ' + BaseName);
    CheckStr(NewName, PNew^.Name, NewName + ': name');
    CheckStr('', PNew^.XDictHandle, NewName + ': extension dictionary handle');
    CheckInt(Count0 + 1, Drawing.DXFMLeaderStyleTable.Count,
      'mleader styles after AddStyle');

    Check(Save2007(CreatedFile, Drawing), 'saved as DXF 2007 -> ' + CreatedFile);
  finally
    DoneDrawing(Drawing);
  end;

  { Повторная загрузка: новый стиль на месте, параметры как у базового;
    затем удаление стиля и сохранение }
  Reloaded.init(nil);
  try
    LoadDrawing(CreatedFile, Reloaded);
    CheckInt(Count0 + 1, Reloaded.DXFMLeaderStyleTable.Count,
      ExtractFileName(CreatedFile) + ' reloaded: mleader styles');
    for I := Low(SourceStyles) to High(SourceStyles) do
      Check(FindStyle(Reloaded, SourceStyles[I]) <> nil,
        ExtractFileName(CreatedFile) + ' reloaded: style ' + SourceStyles[I]);
    PNew := FindStyle(Reloaded, NewName);
    Check(PNew <> nil, ExtractFileName(CreatedFile) + ' reloaded: style ' + NewName);
    if PNew <> nil then
      CheckStr(BaseProps, StyleProps(PNew^, False),
        ExtractFileName(CreatedFile) + ' reloaded: ' + NewName + ' properties');
    PBase := FindStyle(Reloaded, BaseName);
    if PBase <> nil then
      CheckStr(BaseProps, StyleProps(PBase^, False),
        ExtractFileName(CreatedFile) + ' reloaded: ' + BaseName + ' properties');

    writeln('--- delete "', DeletedName, '"');
    PDel := FindStyle(Reloaded, DeletedName);
    Check(PDel <> nil, DeletedName + ' exists before delete');
    if PDel = nil then
      Exit;
    DeleteStyle(Reloaded, PDel);
    Check(FindStyle(Reloaded, DeletedName) = nil, DeletedName + ' deleted');
    CheckInt(Count0, Reloaded.DXFMLeaderStyleTable.Count,
      'mleader styles after delete');
    Check(Save2007(DeletedFile, Reloaded), 'saved as DXF 2007 -> ' + DeletedFile);
  finally
    DoneDrawing(Reloaded);
  end;

  { Удалённого стиля в файле нет, остальные сохранились }
  Reloaded.init(nil);
  try
    LoadDrawing(DeletedFile, Reloaded);
    CheckInt(Count0, Reloaded.DXFMLeaderStyleTable.Count,
      ExtractFileName(DeletedFile) + ' reloaded: mleader styles');
    Check(FindStyle(Reloaded, DeletedName) = nil,
      ExtractFileName(DeletedFile) + ' reloaded: no style ' + DeletedName);
    for I := Low(SourceStyles) to High(SourceStyles) do
      if SourceStyles[I] <> DeletedName then
        Check(FindStyle(Reloaded, SourceStyles[I]) <> nil,
          ExtractFileName(DeletedFile) + ' reloaded: style ' + SourceStyles[I]);
    PNew := FindStyle(Reloaded, NewName);
    Check(PNew <> nil, ExtractFileName(DeletedFile) + ' reloaded: style ' + NewName);
    if PNew <> nil then
      CheckStr(BaseProps, StyleProps(PNew^, False),
        ExtractFileName(DeletedFile) + ' reloaded: ' + NewName + ' properties');
  finally
    DoneDrawing(Reloaded);
  end;
end;

begin
  Root := '';
  if ParamCount > 0 then
    Root := IncludeTrailingPathDelimiter(ParamStr(1));
  Failed := 0;
  try
    CopyPropertiesTest;
  except
    on E: Exception do
      Fail('CopyPropertiesFrom: ' + E.ClassName + ': ' + E.Message);
  end;
  try
    CreateDeleteRoundTrip;
  except
    on E: Exception do
      Fail(Source + ': ' + E.ClassName + ': ' + E.Message);
  end;

  if Failed = 0 then
    writeln('OK')
  else begin
    writeln('FAILED: ', Failed);
    Halt(1);
  end;
end.

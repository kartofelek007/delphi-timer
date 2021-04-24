unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Effects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Filter.Effects;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Timer1: TTimer;
    ShadowEffect1: TShadowEffect;
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LabelMouseEnter(Sender: TObject);
    procedure LabelMouseLeave(Sender: TObject);
    procedure LabelClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  isFullScreen: Boolean;
  TimeTime: Integer;
  Target: TDateTime;
  posX: Integer;
  posY: Integer;
  Labels: array [1 .. 13] of TLabel;

implementation

{$R *.fmx}

procedure TForm1.LabelClick(Sender: TObject);
var
  TheButton: TLabel;
begin
  Timer1.Enabled := true;
  TheButton := Sender as TLabel;
  TimeTime := StrToInt(TheButton.Text);

  if (TheButton.Text = '60') then
  begin
    Target := now() + StrToTime('01:00:01');
  end
  else
  begin
    Target := now() + StrToTime('00:' + TheButton.Text + ':01');
  end;
end;

procedure TForm1.LabelMouseEnter(Sender: TObject);
var
  TheLabel: TLabel;
begin
  TheLabel := Sender as TLabel;
  TheLabel.StyledSettings := TheLabel.StyledSettings - [TStyledSetting.FontColor];
  TheLabel.FontColor := $FFFFFFFF;
end;

procedure TForm1.LabelMouseLeave(Sender: TObject);
var
  TheLabel: TLabel;
begin
  TheLabel := Sender as TLabel;
  TheLabel.StyledSettings := TheLabel.StyledSettings - [TStyledSetting.FontColor];
  TheLabel.FontColor := $20FFFFFF;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
var
  MyButton: TLabel;
var
  times: array [1 .. 13] of string;
begin

  // if LoadResourceFontByID(1, RT_FONT) then Label1.Font.Name := 'Roboto Black';
  // Label1.Font.Size := 180;

  Top := ((Screen.Height - Height) div 2);
  Left := ((Screen.Width - Width) div 2);

  times[1] := '01';
  times[2] := '05';
  times[3] := '10';
  times[4] := '15';
  times[5] := '20';
  times[6] := '25';
  times[7] := '30';
  times[8] := '35';
  times[9] := '40';
  times[10] := '45';
  times[11] := '50';
  times[12] := '55';
  times[13] := '60';

  for i := 1 to Length(times) do
  begin
    MyButton := TLabel.Create(self);
    With MyButton do
    begin
      StyledSettings := MyButton.StyledSettings - [TStyledSetting.Family, TStyledSetting.FontColor, TStyledSetting.Size];
      Position.X := Form1.Width - 80;
      Position.Y := (Form1.Height div 2) - (540 div 2) + (i * 35);
      Width := 30;
      Height := 30;
      AutoSize := false;
      Cursor := crHandPoint;
      HitTest := true;
      TextSettings.FontColor := $20FFFFFF;
      TextSettings.Font.Size := 20;
      TextSettings.Font.Family := 'Roboto Bold';
      TextSettings.Font.Style := MyButton.TextSettings.Font.Style + [TFontStyle.fsBold];
      Text := times[i];
      TextSettings.HorzAlign := TTextAlign.Center;
      TextSettings.VertAlign := TTextAlign.Center;
      Parent := Form1;
      OnClick := LabelClick;
      OnMouseEnter := LabelMouseEnter;
      OnMouseLeave := LabelMouseLeave;
    end;
    Labels[i] := MyButton;
  end;
end;

procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  Timer1.Enabled := false;
  if (WheelDelta > 0) then
  begin
    TimeTime := TimeTime + 1;
    if (TimeTime > 60) then
    begin
      TimeTime := 60;
    end;
  end
  else
  begin
    TimeTime := TimeTime - 1;
    if (TimeTime < 0) then
    begin
      TimeTime := 0;
    end;
  end;

  Target := now() + StrToTime(Format('%.2d:%.2d:01', [TimeTime div 60, TimeTime mod 60]));
  Timer1.Enabled := true;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  isReturnToSmall: Boolean;
begin
  isReturnToSmall := false;
  if ((isFullScreen = true) and (Key = 27)) then // 27 = esc
  begin
    isFullScreen := false;
    isReturnToSmall := true;
  end;

  if (KeyChar = 'f') then
  begin
    isFullScreen := not isFullScreen;
  end;

  if (isFullScreen) then
  begin
    posX := Form1.Left;
    posY := Form1.Top;
    BorderStyle := TFmxFormBorderStyle.None;
    WindowState := TWindowState.wsMaximized;
  end
  else
  begin
    WindowState := TWindowState.wsNormal;
    BorderStyle := TFmxFormBorderStyle.Sizeable;
  end;

  if (isReturnToSmall) then
  begin
    Form1.Left := posX;
    Form1.Top := posY;
    Form1.Width := 950;
    Form1.Height := 580;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
var
  MyButton: TLabel;
var
  i: Integer;
begin
  for i := 1 to Length(Labels) do
  begin
    MyButton := Labels[i];
    With MyButton do
    begin
      Position.X := Form1.Width - 80;
      Position.Y := (Form1.Height div 2) - (540 div 2) + (i * 35);
    end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  TimeToTarget: TDateTime;
  myHour, myMin, mySec, myMilli: Word;
  getMinutes: Word;
  str: String;

  secondInStr: String;
begin
  TimeToTarget := Target - now();
  DecodeTime(TimeToTarget, myHour, myMin, mySec, myMilli);
  getMinutes := myHour * 60 + myMin;
  str := Format('%.*d', [2, getMinutes]) + ':' + Format('%.*d', [2, mySec]);
  Label1.Text := str;
  if (TimeToTarget <= 0) then
  begin
    Timer1.Enabled := false;
  end;
end;

end.

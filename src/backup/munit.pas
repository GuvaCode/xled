unit munit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Controls, Dialogs,
  LCLType, Forms, Process,
  HotKeys;

type
  { TDesignFrm }
  TDesignFrm = class(TDataModule)
    Apr: TApplicationProperties;
    ImageList48: TImageList;
    TrayIcon: TTrayIcon;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
  private
    procedure Light(on_off:Boolean);
    procedure KeyNotify(Sender: TObject; Key: Word; Shift: TShiftState);
    function ScrollLockState: Boolean;
  public

  end;

var
  DesignFrm: TDesignFrm;

implementation

{$R *.lfm}

{ TDesignFrm }
procedure TDesignFrm.DataModuleCreate(Sender: TObject);
begin
 HotkeyCapture.RegisterNotify(VK_SCROLL,[],@KeyNotify);
 ImageList48.GetIcon(ord(ScrollLockState),TrayIcon.Icon);
 TrayIcon.visible:=true;
end;

procedure TDesignFrm.DataModuleDestroy(Sender: TObject);
begin
 Light(true);
 HotkeyCapture.UnRegisterNotify(VK_SCROLL,[]);
 application.Terminate;
end;

procedure TDesignFrm.TrayIconClick(Sender: TObject);
begin
  Light(ScrollLockState);
  ImageList48.GetIcon(ord(ScrollLockState),TrayIcon.Icon)
end;

procedure TDesignFrm.TrayIconDblClick(Sender: TObject);
begin
  if MessageDlg('Question', 'Do you wish to exit?', mtConfirmation,
   [mbYes, mbNo],0) = mrYes then DesignFrm.DoDestroy;
end;

procedure TDesignFrm.Light(on_off: Boolean);
var ShProcess:Tprocess;
begin
    ShProcess := TProcess.Create(nil);
    ShProcess.Options:=[poWaitOnExit,poNoConsole];
    ShProcess.Executable := 'xset';
    If on_off then
     ShProcess.Parameters.Add('-led')
    else
    ShProcess.Parameters.Add('led');
    ShProcess.Execute;
    ShProcess.Free;
end;

procedure TDesignFrm.KeyNotify(Sender: TObject; Key: Word; Shift: TShiftState);
begin
  Light(ScrollLockState);
  ImageList48.GetIcon(ord(ScrollLockState),TrayIcon.Icon)
end;

function TDesignFrm.ScrollLockState: Boolean;
var ShProcess:TProcess;
    cArgs: String;
    Output:TStringList;
begin
    cArgs :=
    Trim(' xset q               ') +
    Trim(' | grep Scroll        ') +
    Trim(' | grep -Eo ''.{3}$'' ') ;

    Output:=TStringList.Create;
  ShProcess := TProcess.Create(nil);
  ShProcess.Executable := '/bin/sh';
  ShProcess.Parameters.Add('-c');
  ShProcess.Parameters.Add(cArgs);
  ShProcess.Options := ShProcess.Options + [poWaitOnExit, poUsePipes];
  ShProcess.Execute;
  Output.LoadFromStream(ShProcess.Output);

  case Trim(Output.Strings[Output.Count-1]) of
  'off' : Result := False;
  'on'  : Result := True;
  end;

  ShProcess.Free;
  Output.Free;
end;






end.


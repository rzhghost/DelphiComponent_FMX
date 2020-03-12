unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Layouts, FMX.Memo,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TfrmNSAlert = class(TForm)
    btnDialogStyle: TButton;
    btnSheetStyle: TButton;
    Button1: TButton;
    procedure btnSheetStyleClick(Sender: TObject);
    procedure btnDialogStyleClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  end;

var
  frmNSAlert: TfrmNSAlert;

implementation

uses Macapi.CocoaTypes, Macapi.Foundation, Macapi.AppKit, CCR.NSAlertHelper,Macapi.CoreFoundation
;

{$R *.fmx}

procedure TfrmNSAlert.btnDialogStyleClick(Sender: TObject);
var
  Alert: NSAlert;
begin
  Alert := TNSAlert.Create;
  try
    Alert.addButtonWithTitle(NSSTR('OK'));
    Alert.addButtonWithTitle(NSSTR('Cancel'));
    Alert.setMessageText(NSSTR('Delete every file on your computer?'));
    Alert.setInformativeText(NSSTR('Deleted files cannot be restored.'));
    Alert.setAlertStyle(NSWarningAlertStyle);
    case Alert.runModal of
      NSAlertFirstButtonReturn: Caption := 'You pressed OK';
      NSAlertSecondButtonReturn: Caption := 'You pressed Cancel';
    else
      Caption := 'Er, something went wrong here...';
    end;
  finally
    Alert.release;
  end;
end;

procedure TfrmNSAlert.btnSheetStyleClick(Sender: TObject);
var
  Alert: NSAlert;
begin
  Alert := TNSAlert.Create;
  Alert.addButtonWithTitle(NSSTR('OK'));
  Alert.addButtonWithTitle(NSSTR('Cancel'));
  Alert.setMessageText(NSSTR('Delete every file on your computer?'));
  Alert.setInformativeText(NSSTR('Deleted files cannot be restored.'));
  Alert.setAlertStyle(NSWarningAlertStyle);
  ShowNSAlertAsSheet(Alert, Self,
    procedure (ReturnCode: NSInteger)
    begin
      case ReturnCode of
        NSAlertFirstButtonReturn: Caption := 'You pressed OK';
        NSAlertSecondButtonReturn: Caption := 'You pressed Cancel';
      else
        Caption := 'Er, something went wrong here...';
      end;
      Alert.release;
    end);
end;

procedure ShowMessageCF(const AHeading, AMessage: string; const ATimeoutInSecs: Double = 0);
var
  LHeading, LMessage: CFStringRef;
  LResponse: CFOptionFlags;
begin
  LHeading := CFStringCreateWithCharactersNoCopy(nil, PWideChar(AHeading),
    Length(AHeading), kCFAllocatorNull);
  LMessage := CFStringCreateWithCharactersNoCopy(nil, PWideChar(AMessage),
    Length(AMessage), kCFAllocatorNull);
  try
    CFUserNotificationDisplayAlert(ATimeoutInSecs, kCFUserNotificationNoteAlertLevel,
      nil, nil, nil, LHeading, LMessage, nil, nil, nil, LResponse);
  finally
    CFRelease(LHeading);
    CFRelease(LMessage);
  end;
end;

procedure TfrmNSAlert.Button1Click(Sender: TObject);
begin
  ShowMessageCF('Test', 'This dialog will auto-destruct in 10 seconds!', 10);
end;

end.

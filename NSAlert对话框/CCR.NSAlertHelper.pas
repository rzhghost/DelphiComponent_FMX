unit CCR.NSAlertHelper;

interface

uses
  Macapi.CocoaTypes, Macapi.Foundation, Macapi.AppKit, FMX.Forms;

type
  TNSAlertClosedEvent = reference to procedure (ReturnCode: NSInteger);

procedure ShowNSAlertAsSheet(const Alert: NSAlert; Form: TCommonCustomForm;
  const AOnClose: TNSAlertClosedEvent);

function NSWindowOfForm(Form: TCommonCustomForm): NSWindow;

implementation

uses
  System.TypInfo, Macapi.CoreFoundation, Macapi.ObjCRuntime, Macapi.ObjectiveC, FMX.Platform.Mac;

type
  IAlertDelegate = interface(NSObject)
    ['{E4B7CA83-5351-4BE7-89BB-25A9C70D89D0}']
    procedure alertDidEnd(alert: Pointer; returnCode: NSInteger; contextInfo: Pointer); cdecl;
  end;

  TAlertDelegate = class(TOCLocal)
  strict private
    FOnClose: TNSAlertClosedEvent;
  protected
    function GetObjectiveCClass: PTypeInfo; override;
  public
    constructor Create(const AOnClose: TNSAlertClosedEvent);
    procedure alertDidEnd(alert: Pointer; returnCode: NSInteger; contextInfo: Pointer); cdecl;
    destructor Destroy; override;
  end;

  TOCLocalAccess = class(TOCLocal);

function NSWindowOfForm(Form: TCommonCustomForm): NSWindow;
begin
  Result := NSWindow(WindowHandleToPlatform(Form.Handle).Wnd);
end;

constructor TAlertDelegate.Create(const AOnClose: TNSAlertClosedEvent);
begin
  inherited Create;
  FOnClose := AOnClose;
end;

destructor TAlertDelegate.Destroy;
begin
  CFRelease(GetObjectID);
  inherited;
end;

function TAlertDelegate.GetObjectiveCClass: PTypeInfo;
begin
  Result := TypeInfo(IAlertDelegate);
end;

procedure TAlertDelegate.alertDidEnd(alert: Pointer; returnCode: NSInteger;
  contextInfo: Pointer);
begin
  FOnClose(returnCode);
  Destroy;
end;

procedure ShowNSAlertAsSheet(const Alert: NSAlert; Form: TCommonCustomForm;
  const AOnClose: TNSAlertClosedEvent);
var
  Delegate: TAlertDelegate;
begin
  Delegate := TAlertDelegate.Create(AOnClose);
  Alert.beginSheetModalForWindow(NSWindowOfForm(Form), Delegate.GetObjectID,
    sel_getUid('alertDidEnd:returnCode:contextInfo:'), nil);
end;

end.

unit uSyncWebImage;

interface

uses
  System.SysUtils, System.Classes, System.Types, FMX.Types, FMX.Controls, FMX.Objects,
  FMX.StdCtrls, System.Threading, System.Net.HttpClient, FMX.PlatForm, FMX.MediaLibrary, System.Messaging;

type
  TSyncWebImage = class(TImage)
  private
    { Private declarations }
    FURL: string; //web url
    FClient: THTTPClient;
    ProgressBar: TProgressBar;
    FGlobalStart: Cardinal;
    FAsyncResult: IAsyncResult;
    FDownloadStream: TStream;
    procedure SetURL(const Value: string);
    procedure DoEndDownload(const AsyncResult: IAsyncResult);
    procedure ReceiveDataEvent(const Sender: TObject; AContentLength,
      AReadCount: Int64; var Abort: Boolean);
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure Download;
    procedure CancelDownLoad;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property URL:string read FURL write SetURL;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RFMX', [TSyncWebImage]);
end;

{ TSyncWebImage }

constructor TSyncWebImage.Create(AOwner: TComponent);
begin
  inherited;
  FClient := THTTPClient.Create;
  FClient.ConnectionTimeout := 90000;
  FClient.ResponseTimeout := 90000;
  //以常用方式访问,有些服务器会限制非标准请求
  FClient.UserAgent := 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Safari/605.1.15';
  FClient.OnReceiveData := ReceiveDataEvent;
  ProgressBar:= TProgressBar.Create(Self);
  with ProgressBar do
  begin
    Parent :=Self;
    ProgressBar.Align := TAlignLayout.Bottom;
    Height :=5;
    Visible:=False;
  end;
end;

destructor TSyncWebImage.Destroy;
begin
  CancelDownLoad;
  if Assigned(FDownloadStream) then
    FDownloadStream.Free;
  FClient.Free;
  ProgressBar.Free;
  inherited;
end;

procedure TSyncWebImage.ReceiveDataEvent(const Sender: TObject; AContentLength, AReadCount: Int64;
  var Abort: Boolean);
//var
  //LTime: Cardinal;
  //LSpeed: Integer;
begin
  //LTime := TThread.GetTickCount - FGlobalStart;
  //LSpeed := (AReadCount * 1000) div LTime;
  TThread.Queue(nil,
    procedure
    begin
      ProgressBar.Value := AReadCount;
//      Canvas.BeginScene();
//      Canvas.Fill.Color := $FF0000;
//      Canvas.FillText(BoundsRect,Format('%d KB/s', [LSpeed div 1024]),false,1,[],TTextAlign.Center ,TTextAlign.Center);
//      Canvas.EndScene;
    end);
end;

procedure TSyncWebImage.CancelDownLoad;
begin
  if Assigned(FAsyncResult) then
    FAsyncResult.Cancel;
end;

procedure TSyncWebImage.Download;
var
  LResponse: IHTTPResponse;
  LSize: Int64;
begin
  if Trim(URL)='' then exit;

  // Start the download process
  LResponse := FClient.Head(URL);
  LSize := LResponse.ContentLength;
  LResponse := nil;

  ProgressBar.Visible := True;
  ProgressBar.Max := LSize;
  ProgressBar.Min := 0;
  ProgressBar.Value := 0;

  // Create the file that is going to be dowloaded
  FDownloadStream := TMemoryStream.Create;
  FDownloadStream.Position := 0;

  FGlobalStart := TThread.GetTickCount;
  FAsyncResult := FClient.BeginGet(DoEndDownload, FURL, FDownloadStream);
end;

procedure TSyncWebImage.DoEndDownload(const AsyncResult: IAsyncResult);
var
  LAsyncResponse: IHTTPResponse;
begin
  try
    LAsyncResponse := THTTPClient.EndAsyncHTTP(AsyncResult);
    TThread.Synchronize(nil,
      procedure
      begin
        if LAsyncResponse.StatusCode=200 then
        begin
          FDownloadStream.Position := 0;
          Self.bitmap.LoadFromStream(FDownloadStream);
          ProgressBar.Visible := False;
          self.Repaint;
        end;
      end);
  finally
    LAsyncResponse := nil;
    FreeandNil(FDownloadStream);
  end;
end;

procedure TSyncWebImage.SetURL(const Value: string);
begin
  FURL := Value;
  if (Trim(FURL)<>'') then
  begin
    TThread.CreateAnonymousThread(
      procedure
      begin
        DownLoad;
      end).Start;
  end
  else
  begin
    Self.Bitmap.Clear(0);
  end;
end;

end.

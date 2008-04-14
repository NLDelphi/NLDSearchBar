unit NLDSBForm;

interface
uses
  Windows,
  SysUtils,
  Forms,
  Controls,
  NLDSBExplorerBar,
  SHDocVw;

type
  {
    :$ Contains the necessary code to make a frame function as an
    :$ Internet Explorer toolbar
  }
  TNLDSBForm  = class(TForm, IBandClass)
  private
    FBrowser:         IWebBrowserApp;
    FExplorer:        TInternetExplorer;
  protected
    procedure Loaded(); override;

    // IBandClass
    procedure SetWebBrowserApp(const ABrowser: IWebBrowserApp);

    // Available for overriding...
    procedure BeforeNavigate(Sender: TObject; var pDisp: OleVariant;
                             var URL: OleVariant; var Flags: OleVariant;
                             var TargetFrameName: OleVariant;
                             var PostData: OleVariant; var Headers: OleVariant;
                             var Cancel: OleVariant); virtual;
  public
    property Browser:     IWebBrowserApp    read FBrowser;
    property Explorer:    TInternetExplorer read FExplorer;
  end;

{$R *.DFM}

implementation

{****************************************
  TNLDSBForm
****************************************}
procedure TNLDSBForm.BeforeNavigate;
begin
  // Do nothing...
end;


procedure TNLDSBForm.Loaded;
begin
  inherited;

  // Make sure we never have a border...
  BorderStyle := bsNone;
  Visible     := True;
  TabStop     := True;
end;


procedure TNLDSBForm.SetWebBrowserApp;
{
var
  ifBrowser:        IWebBrowser2;
}

begin
  FBrowser  := ABrowser;

  { Causes random IE crashes, still have to figure out why...
  if Assigned(FBrowser) then begin
    if Supports(FBrowser, IWebBrowser2, ifBrowser) then begin
      FExplorer := TInternetExplorer.Create(nil);
      FExplorer.ConnectTo(ifBrowser);
      FExplorer.OnBeforeNavigate2 := BeforeNavigate;
      ifBrowser := nil;
    end else
      FreeAndNil(FExplorer);
  end else
    FreeAndNil(FExplorer);
  }
end;

end.

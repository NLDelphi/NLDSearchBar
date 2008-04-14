unit FSearchBar;

interface
uses
  Windows,
  SysUtils,
  Forms,
  Classes,
  NLDSBExplorerBar,
  NLDSBForm,
  OleCtrls,
  Controls,
  StdCtrls,
  ImgList,
  ComCtrls,
  ToolWin,
  SHDocVw,
  Dialogs,
  ExtCtrls,
  Menus;

type
  TfrmSearchBar = class(TNLDSBForm)
    ilsSearch:            TImageList;
    tlbSearch:            TToolBar;
    tbSearch:             TToolButton;
    pnlSearch:            TPanel;
    cmbSearch:            TComboBox;
    tlbNLDelphi:          TToolBar;
    tbNLDelphi:           TToolButton;
    ilsNLDelphi:          TImageList;
    mnuNLDelphi:          TPopupMenu;
    mnuWebsite:           TMenuItem;
    mnuForum:             TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure tbSearchClick(Sender: TObject);
    procedure cmbSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cmbSearchKeyPress(Sender: TObject; var Key: Char);
    procedure mnuWebsiteClick(Sender: TObject);
    procedure mnuForumClick(Sender: TObject);
  private
    procedure Search(const AQuery: String; const ANewWindow: Boolean = False);
    procedure OpenURL(const AURL: String);
  protected
    procedure BeforeNavigate(Sender: TObject; var pDisp: OleVariant;
                             var URL: OleVariant; var Flags: OleVariant;
                             var TargetFrameName: OleVariant;
                             var PostData: OleVariant; var Headers: OleVariant;
                             var Cancel: OleVariant); override;
  end;

implementation
uses
  IdURI,
  Registry;
  
const
  // The URL to match when checking for search queries
  CMatchURLPrefix   = 'http://www.nldelphi.com/cgi-bin/texis.exe/' +
                      'Webinator/search/';

  // This should be the default, however, due to a server configuration
  // mistake we'll just work around it for now...
  //CSearchURL:   String    = 'http://zoek.nldelphi.com/?query=%s';
  CSearchURL        = CMatchURLPrefix + '?query=%s';

  // Some links
  CWebsiteURL       = 'http://www.nldelphi.com/';
  CForumURL         = CWebsiteURL + 'forum/';

  // Maybe add an option for this later?
  CMaxHistory       = 20;

{$R *.dfm}

{****************************************
  TfrmSearchBar
****************************************}
procedure TfrmSearchBar.FormCreate;
var
  regHistory:       TRegistry;
  iSize:            Integer;
  sData:            String;

begin
  regHistory  := TRegistry.Create();
  try
    regHistory.RootKey  := HKEY_CURRENT_USER;

    if regHistory.OpenKey('Software\NLDelphi\NLDSearchBar', False) then begin
      if regHistory.ValueExists('Data') then begin
        iSize := regHistory.GetDataSize('Data');

        SetLength(sData, iSize);
        regHistory.ReadBinaryData('Data', PChar(sData)^, iSize);

        cmbSearch.Items.Text  := sData;
      end;
    end;
  finally
    FreeAndNil(regHistory);
  end;
end;


procedure TfrmSearchBar.tbSearchClick;
begin
  Search(cmbSearch.Text);
end;

procedure TfrmSearchBar.cmbSearchKeyDown;
begin
  if Key = VK_RETURN then
    Search(cmbSearch.Text, (ssShift in Shift));
end;

procedure TfrmSearchBar.cmbSearchKeyPress;
begin
  if Key = #13 then
    Key := #0;
end;



{****************************************
  Search
****************************************}
procedure TfrmSearchBar.Search;
var
  sQuery:             String;
  ifNewBrowser:       IWebBrowser2;
  regHistory:         TRegistry;
  iSize:              Integer;
  sData:              String;
  iItem:              Integer;
  bFound:             Boolean;

begin
  sQuery  := Trim(AQuery);
  if Length(sQuery) = 0 then
    exit;

  // Add the item to the history, or move it to the front...
  bFound  := False;

  for iItem := 0 to cmbSearch.Items.Count - 1 do
    if CompareText(cmbSearch.Items[iItem], sQuery) = 0 then begin
      cmbSearch.Items.Move(iItem, 0);
      
      bFound  := True;
      break;
    end;

  if not bFound then
    cmbSearch.Items.Insert(0, sQuery);

  // Write new URL list
  regHistory  := TRegistry.Create();
  try
    regHistory.RootKey  := HKEY_CURRENT_USER;

    if regHistory.OpenKey('Software\NLDelphi\NLDSearchBar', True) then begin
      sData := cmbSearch.Items.Text;
      iSize := Length(sData);

      regHistory.WriteBinaryData('Data', PChar(sData)^, iSize);
    end;
  finally
    FreeAndNil(regHistory);
  end;

  sQuery  := Format(CSearchURL, [sQuery]);

  // We *could* use either the flags parameter (navOpenInNewWindow) or
  // set the target frame to '_blank'. However, testing showed that using
  // either method in combination with XenoBar (a popup killer), XenoBar will
  // recognize the action as a 'popup' action instead of a 'new window' action,
  // thus block it by default.
  if ANewWindow then begin
    ifNewBrowser  := CoInternetExplorer.Create();
    ifNewBrowser._AddRef();

    ifNewBrowser.Visible  := True;
    ifNewBrowser.RegisterAsBrowser  := True;
    ifNewBrowser.Navigate(sQuery, EmptyParam, EmptyParam,
                          EmptyParam, EmptyParam);
    ifNewBrowser  := nil;
  end else
    OpenURL(sQuery);
end;

procedure TfrmSearchBar.OpenURL;
begin
  Browser.Navigate(AURL, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;


{****************************************
  Before Navigation
****************************************}
procedure TfrmSearchBar.BeforeNavigate;
var
  sURL:         String;
  idURI:        TIdURI;
  slParams:     TStringList;
  pParams:      PChar;
  pSearch:      PChar;
  sParam:       String;

begin
  sURL  := URL;

  // Check for valid URL
  if CompareText(Copy(sURL, 1, Length(CMatchURLPrefix)), CMatchURLPrefix) = 0 then begin
    idURI := TIdURI.Create(sURL);
    try
      // Kind of 'stolen' from IdHTTP
      slParams  := TStringList.Create();
      try
        sURL    := Copy(idURI.Params, 2, MaxInt);
        pParams := PChar(sURL);
        pSearch := pParams;

        while (pSearch <> nil) and (pSearch[0] <> #0) do begin
          pSearch := StrScan(pParams, '&');

          if pSearch = nil then begin
            pSearch := StrEnd(pParams);
          end;

          SetString(sParam, pParams, pSearch - pParams);
          slParams.Add(TIdURI.URLDecode(sParam));
          pParams := pSearch + 1;
        end;

        // Check for 'query' parameter
        sURL  := slParams.Values['query'];
        if Length(sURL) > 0 then
          cmbSearch.Text  := sURL;
      finally
        FreeAndNil(slParams);
      end;
    finally
      FreeAndNil(idURI);
    end;
  end;
end;


procedure TfrmSearchBar.mnuWebsiteClick;
begin
  OpenURL(CWebsiteURL);
end;


procedure TfrmSearchBar.mnuForumClick;
begin
  OpenURL(CForumURL);
end;


initialization
  // Register band class
  NLDSBExplorerBar.BandClass  := TfrmSearchBar;
  
end.

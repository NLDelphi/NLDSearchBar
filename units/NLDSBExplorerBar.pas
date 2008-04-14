unit NLDSBExplorerBar;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows,
  Messages,
  Forms,
  SysUtils,
  ActiveX,
  Classes,
  ComObj,
  ShlObj,
  Controls,
  SHDocVw,
  NLDSearchBar_TLB,
  StdVcl;

const
  IID_IBandClass:     TGUID     = '{81ED334A-1C4F-47FE-9EC0-C6B29116981D}';

type
  {
    :$ Provides an interface for the band class to get information
    :$ about the environment
  }
  IBandClass  = interface
    ['{81ED334A-1C4F-47FE-9EC0-C6B29116981D}']
    procedure SetWebBrowserApp(const ABrowser: IWebBrowserApp);
  end;


  {
    :$ Implements the Internet Explorer toolbar interfaces
  }
  TNLDSBExplorerBar = class(TTypedComObject, INLDSBExplorerBar, IOleWindow,
                            IDeskBand, IObjectWithSite, IPersistStream,
                            IContextMenu, IInputObject)
  private
    FBand:          TWinControl;
    FSite:          IUnknown;
    FParentWnd:     HWND;
    FHasFocus:      Boolean;
    FOldWndProc:    TWndMethod;

    procedure WndProc(var Message: TMessage);
    procedure FocusChange(const AFocus: Boolean);
  protected
    // IOleWindow
    function GetWindow(out wnd: HWnd): HResult; virtual; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;

    // IDockingWindow (implicit interface from IDeskBand)
    function ShowDW(fShow: BOOL): HResult; stdcall;
    function CloseDW(dwReserved: DWORD): HResult; stdcall;
    function ResizeBorderDW(var prcBorder: TRect; punkToolbarSite: IUnknown;
                            fReserved: BOOL): HResult; stdcall;

    // IDeskBand
    function GetBandInfo(dwBandID, dwViewMode: DWORD; var pdbi: TDeskBandInfo):
                         HResult; stdcall;

    // IObjectWithSite
    function SetSite(const pUnkSite: IUnknown ):HResult; stdcall;
    function GetSite(const riid: TIID; out site: IUnknown):HResult; stdcall;

    // IPersist (implicit interface from IPersistStream)
    function GetClassID(out classID: TCLSID): HResult; stdcall;

    // IPersistStream
    function IsDirty: HResult; stdcall;
    function Load(const stm: IStream): HResult; stdcall;
    function Save(const stm: IStream; fClearDirty: BOOL): HResult; stdcall;
    function GetSizeMax(out cbSize: Largeint): HResult; stdcall;

    // IContextMenu
    function QueryContextMenu(Menu: HMENU; indexMenu, idCmdFirst, idCmdLast,
                              uFlags: UINT): HResult; stdcall;
    function InvokeCommand(var lpici: TCMInvokeCommandInfo): HResult; stdcall;
    function GetCommandString(idCmd, uType: UINT; pwReserved: PUINT;
                              pszName: LPSTR; cchMax: UINT): HResult; stdcall;

    // IInputObject
    function UIActivateIO(fActivate: BOOL; var lpMsg: TMsg): HResult; stdcall;
    function HasFocusIO(): HResult; stdcall;
    function TranslateAcceleratorIO(var lpMsg: TMsg): HResult; stdcall;
  public
    property Band:    TWinControl   read FBand  write FBand;
    property Site:    IUnknown      read FSite  write FSite;
  end;


  {
    :$ Handles the registration of the DeskBand
  }
  TNLDSBFactory     = class(TTypedComObjectFactory)
  protected
    procedure AddKeys(); virtual;
    procedure RemoveKeys(); virtual;
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;


var
  BandClass:        TWinControlClass;

const
  CBarName:         String    = '&NLDelphi ZoekBar';


implementation
uses
  ComServ,
  Registry;

type
  // Provides access to the protected members
  THackWinControl = class(TWinControl);

const
  KEY_Discardable = 'Software\Microsoft\Windows\CurrentVersion\Explorer\' +
                    'Discardable\PostSetup\Component Categories\%s\Enum';
  KEY_Vertical    = '{00021493-0000-0000-C000-000000000046}';
  KEY_Horizontal  = '{00021494-0000-0000-C000-000000000046}';



{********************** TNLDSBExplorerBar
  Focus
****************************************}
procedure TNLDSBExplorerBar.FocusChange;
var
  ifSite:       IInputObjectSite;

begin
  FHasFocus := AFocus;

  if Assigned(FSite) then
    if Supports(FSite, IInputObjectSite, ifSite) then begin
      ifSite.OnFocusChangeIS(Self, FHasFocus);
      ifSite  := nil;
    end;
end;


{********************** TNLDSBExplorerBar
  IOleWindow
****************************************}
function TNLDSBExplorerBar.ContextSensitiveHelp;
begin
  Result  := E_NOTIMPL;
end;

function TNLDSBExplorerBar.GetWindow;
begin
  wnd     := FBand.Handle;
  Result  := S_OK;
end;


{********************** TNLDSBExplorerBar
  IDockingWindow
****************************************}
function TNLDSBExplorerBar.ShowDW;
begin
  FocusChange(fShow);
  Result  := S_OK;
end;

function TNLDSBExplorerBar.CloseDW;
begin
  FreeAndNil(FBand);
  Result  := S_OK;
end;

function TNLDSBExplorerBar.ResizeBorderDW;
begin
  Result  := E_NOTIMPL;
end;


{********************** TNLDSBExplorerBar
  IDeskBand
****************************************}
function TNLDSBExplorerBar.GetBandInfo;
  // Returns -1 if the value is 0, the value otherwise...
  function HandleZero(const AValue: Integer): Integer;
  begin
    if AValue = 0 then
      Result  := -1
    else
      Result  := AValue;
  end;

var
  sCaption:       String;
  iLength:        Integer;

begin
  // Minimum size
  if (pdbi.dwMask and DBIM_MINSIZE) = DBIM_MINSIZE then begin
    pdbi.ptMinSize.x  := HandleZero(FBand.Constraints.MinWidth);
    pdbi.ptMinSize.y  := HandleZero(FBand.Constraints.MinHeight);
  end;

  // Maximum size
  if (pdbi.dwMask and DBIM_MAXSIZE) = DBIM_MAXSIZE then begin
    pdbi.ptMaxSize.x  := HandleZero(FBand.Constraints.MaxWidth);
    pdbi.ptMaxSize.y  := HandleZero(FBand.Constraints.MaxHeight);
  end;

  // Ideal size
  if (pdbi.dwMask and DBIM_ACTUAL) = DBIM_ACTUAL then begin
    pdbi.ptActual.x   := FBand.Width;
    pdbi.ptActual.y   := FBand.Height;
  end;

  // Integral size
  if (pdbi.dwMask and DBIM_INTEGRAL) = DBIM_INTEGRAL then begin
    pdbi.ptIntegral.x := 1;
    pdbi.ptIntegral.y := 1;
  end;

  // Mode
  if (pdbi.dwMask and DBIM_MODEFLAGS) = DBIM_MODEFLAGS then
    pdbi.dwModeFlags := DBIMF_NORMAL;

  // Back color
  if (pdbi.dwMask and DBIM_BKCOLOR) = DBIM_BKCOLOR then
    pdbi.dwMask := pdbi.dwMask and (not DBIM_BKCOLOR);

  // Title
  if (pdbi.dwMask and DBIM_TITLE) = DBIM_TITLE then begin
    // Use a maximum of 255 characters
    sCaption  := Copy(THackWinControl(FBand).Text, 1, 255);
    iLength   := Length(sCaption) + 1;

    // Convert to wide string
    FillChar(pdbi.wszTitle, iLength, #0);
    StringToWideChar(sCaption, @pdbi.wszTitle, iLength);
  end;

  Result  := S_OK;
end;


{********************** TNLDSBExplorerBar
  IObjectWithSite
****************************************}
function TNLDSBExplorerBar.SetSite;
var
  ifProvider:         IServiceProvider;
  ifBandClass:        IBandClass;
  ifBrowser:          IWebBrowserApp;
  ifWindow:           IOleWindow;

begin
  FSite       := pUnkSite;
  FParentWnd  := 0;

  if Assigned(FSite) then begin
    // Get parent window
    if Supports(FSite, IOleWindow, ifWindow) then begin
      ifWindow.GetWindow(FParentWnd);
      ifWindow  := nil;
    end;

    // Create a new band window...
    FBand             := BandClass.CreateParented(FParentWnd);
    FOldWndProc       := FBand.WindowProc;
    FBand.WindowProc  := Self.WndProc;

    // Get browser reference
    if Supports(FBand, IBandClass, ifBandClass) then begin
      if Supports(FSite, IServiceProvider, ifProvider) then begin
        if ifProvider.QueryService(IWebbrowserApp,
                                   IWebbrowser2, ifBrowser) = 0 then begin
          ifBandClass.SetWebBrowserApp(ifBrowser);
          ifBrowser := nil;
        end;

        ifProvider  := nil;
      end;

      ifBandClass := nil;
    end;
  end else
    // No site provided, close the bar...
    CloseDW(0);

  Result  := S_OK;
end;

function TNLDSBExplorerBar.GetSite;
begin
  Result  := FSite.QueryInterface(riid, site);
end;


{********************** TNLDSBExplorerBar
  IPersist
****************************************}
function TNLDSBExplorerBar.GetClassID(out classID: TCLSID): HResult;
begin
  classID := CLASS_NLDSBExplorerBar;
  Result  := S_OK;
end;


{********************** TNLDSBExplorerBar
  IPersistStream
****************************************}
function TNLDSBExplorerBar.IsDirty;
begin
  Result  := E_NOTIMPL;
end;


function TNLDSBExplorerBar.Load;
begin
  Result  := E_NOTIMPL;
end;

function TNLDSBExplorerBar.Save;
begin
  Result  := E_NOTIMPL;
end;


function TNLDSBExplorerBar.GetSizeMax;
begin
  Result  := E_NOTIMPL;
end;


{********************** TNLDSBExplorerBar
  IContextMenu
****************************************}
function TNLDSBExplorerBar.QueryContextMenu;
begin
  InsertMenu(Menu, 0, MF_BYPOSITION, idCmdFirst, '&Over NLDSearchBar...');
  InsertMenu(Menu, 1, MF_BYPOSITION or MF_SEPARATOR, 0, nil);

  Result  := 2;
end;

function TNLDSBExplorerBar.InvokeCommand;
begin
  case LOWORD(lpici.lpVerb) of
    0:
      MessageBox(lpici.hwnd, 'NLDSearchBar - http://www.nldelphi.com/', 'About...', MB_OK or
                 MB_ICONINFORMATION);
  end;

  Result  := S_OK;
end;

function TNLDSBExplorerBar.GetCommandString;
begin
  Result  := E_NOTIMPL;
end;


{********************** TNLDSBExplorerBar
  IInputObject
****************************************}
function TNLDSBExplorerBar.UIActivateIO;
begin
  FHasFocus := fActivate;

  if FHasFocus then
    FBand.SetFocus();

  Result := S_OK;
end;

function TNLDSBExplorerBar.HasFocusIO;
begin
  Result  := Integer(not FHasFocus);
end;

function TNLDSBExplorerBar.TranslateAcceleratorIO;
begin
  if lpMsg.WParam <> VK_TAB then begin
    TranslateMessage(lpMSg);
    DispatchMessage(lpMsg);
    Result := S_OK;
  end else
    Result := S_FALSE;
end;


{********************** TNLDSBExplorerBar
  Window Procedure
****************************************}
procedure TNLDSBExplorerBar.WndProc;
begin
  if (Message.Msg = WM_PARENTNOTIFY) then
    FocusChange(True);

  FOldWndProc(Message);
end;


{****************************************
  TNLDSBFactory
****************************************}
procedure TNLDSBFactory.UpdateRegistry;
begin
  inherited;

  if Register then
    AddKeys()
  else
    RemoveKeys();
end;


procedure TNLDSBFactory.AddKeys;
var
  sGUID:      String;
  sKey:       String;

begin
  sGUID := GUIDToString(Self.ClassID);

  with TRegistry.Create() do
    try
      RootKey := HKEY_CURRENT_USER;

      // http://support.microsoft.com/support/kb/articles/Q247/7/05.ASP
      sKey  := Format(KEY_Discardable, [KEY_Vertical]);
      DeleteKey(sKey);

      sKey  := Format(KEY_Discardable, [KEY_Horizontal]);
      DeleteKey(sKey);

      RootKey := HKEY_CLASSES_ROOT;

      // Register band
      if OpenKey('CLSID\' + sGUID, True) then begin
        WriteString('', CBarName);
        CloseKey();
      end;

      if OpenKey('CLSID\' + sGUID + '\InProcServer32', True) then begin
        WriteString('ThreadingModel', 'Apartment');
        CloseKey();
      end;

      if OpenKey('CLSID\' + sGUID + '\Implemented Categories\' + KEY_Horizontal, True) then
        CloseKey();

      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\Microsoft\Internet Explorer\Toolbar', True) then begin
        WriteString(sGUID, '');
        CloseKey();
      end;
    finally
      Free();
    end;
end;

procedure TNLDSBFactory.RemoveKeys;
var
  sGUID:      String;

begin
  sGUID := GUIDToString(Self.ClassID);

  with TRegistry.Create() do
    try
      RootKey := HKEY_CLASSES_ROOT;
      DeleteKey('CLSID\' + sGUID + '\Implemented Categories\' + KEY_Horizontal);
      DeleteKey('CLSID\' + sGUID + '\InProcServer32');
      DeleteKey('CLSID\' + sGUID);

      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Microsoft\Internet Explorer\Toolbar', False) then begin
        DeleteValue(sGUID);
        CloseKey();
      end;
    finally
      Free();
    end;
end;


initialization
  TNLDSBFactory.Create(ComServer, TNLDSBExplorerBar, Class_NLDSBExplorerBar,
                       ciMultiInstance, tmApartment);
end.

library NLDSearchBar;

uses
  ComServ,
  NLDSearchBar_TLB in 'NLDSearchBar_TLB.pas',
  NLDSBExplorerBar in 'Units\NLDSBExplorerBar.pas' {NLDSBExplorerBar: CoClass},
  NLDSBForm in 'Forms\NLDSBForm.pas' {NLDSBForm: TForm},
  FSearchBar in 'Forms\FSearchBar.pas' {fraSearchBar: TForm};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}
{$R *.RES}

begin
end.

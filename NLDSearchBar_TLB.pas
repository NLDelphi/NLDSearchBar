unit NLDSearchBar_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.130.1.0.1.0.1.6  $
// File generated on 3-3-2003 19:11:39 from Type Library described below.

// ************************************************************************  //
// Type Lib: F:\Delphi\NLDelphi\NLDSearchBar\NLDSearchBar.tlb (1)
// LIBID: {7061E09A-52F2-4D3D-B911-2C0BFD5863DD}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\System32\STDOLE2.TLB)
//   (2) v4.0 StdVCL, (C:\WINDOWS\System32\stdvcl40.dll)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  NLDSearchBarMajorVersion = 1;
  NLDSearchBarMinorVersion = 0;

  LIBID_NLDSearchBar: TGUID = '{7061E09A-52F2-4D3D-B911-2C0BFD5863DD}';

  IID_INLDSBExplorerBar: TGUID = '{1E8D86AE-4F12-4CFB-8389-759904E166B6}';
  CLASS_NLDSBExplorerBar: TGUID = '{4A249E71-D7EF-411B-96D5-937022C8F81C}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  INLDSBExplorerBar = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  NLDSBExplorerBar = INLDSBExplorerBar;


// *********************************************************************//
// Interface: INLDSBExplorerBar
// Flags:     (256) OleAutomation
// GUID:      {1E8D86AE-4F12-4CFB-8389-759904E166B6}
// *********************************************************************//
  INLDSBExplorerBar = interface(IUnknown)
    ['{1E8D86AE-4F12-4CFB-8389-759904E166B6}']
  end;

// *********************************************************************//
// The Class CoNLDSBExplorerBar provides a Create and CreateRemote method to          
// create instances of the default interface INLDSBExplorerBar exposed by              
// the CoClass NLDSBExplorerBar. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoNLDSBExplorerBar = class
    class function Create: INLDSBExplorerBar;
    class function CreateRemote(const MachineName: string): INLDSBExplorerBar;
  end;

implementation

uses ComObj;

class function CoNLDSBExplorerBar.Create: INLDSBExplorerBar;
begin
  Result := CreateComObject(CLASS_NLDSBExplorerBar) as INLDSBExplorerBar;
end;

class function CoNLDSBExplorerBar.CreateRemote(const MachineName: string): INLDSBExplorerBar;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_NLDSBExplorerBar) as INLDSBExplorerBar;
end;

end.

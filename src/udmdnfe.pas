unit udmdnfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZDataset;

type

  { TdmdNFe }

  TdmdNFe = class(TDataModule)
    qryNFeCab: TZQuery;
    qryNFeDet: TZQuery;
    qryNFePgt: TZQuery;
    qryNFeVol: TZQuery;
    qryNFeDup: TZQuery;
    qryNFeFat: TZQuery;
    cmdCreateTables: TZQuery;
  private

  public

  end;

var
  dmdNFe: TdmdNFe;

implementation

{$R *.lfm}

end.


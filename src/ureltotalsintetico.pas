unit ureltotalsintetico;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RLReport;

type

  { TrelTotaisSintetico }

  TrelTotaisSintetico = class(TForm)
    rlrTotaisSintetico: TRLReport;
    rlbCabecalho: TRLBand;
    rllTitulo: TRLLabel;
    rllPeriodo: TRLLabel;
    rsiDataHora: TRLSystemInfo;
    rsiPagina: TRLSystemInfo;
    rlbTitulos: TRLBand;
    rllDia: TRLLabel;
    rllQtdVendas: TRLLabel;
    rllTotVendas: TRLLabel;
    rllQtdProdutos: TRLLabel;
    rllICMS: TRLLabel;
    rllPIS: TRLLabel;
    rllCOFINS: TRLLabel;
    rllIPI: TRLLabel;
    rllII: TRLLabel;
    rllIS: TRLLabel;
    rllCBS: TRLLabel;
    rllIBSMun: TRLLabel;
    rllIBSUF: TRLLabel;
    rlbDetalhe: TRLBand;
    rdtDia: TRLDBText;
    rdtQtdVendas: TRLDBText;
    rdtTotVendas: TRLDBText;
    rdtQtdProdutos: TRLDBText;
    rdtICMS: TRLDBText;
    rdtPIS: TRLDBText;
    rdtCOFINS: TRLDBText;
    rdtIPI: TRLDBText;
    rdtII: TRLDBText;
    rdtIS: TRLDBText;
    rdtCBS: TRLDBText;
    rdtIBSMun: TRLDBText;
    rdtIBSUF: TRLDBText;
    rlbTotal: TRLBand;
    rllTotal: TRLLabel;
    rdrQtdVendas: TRLDBResult;
    rdrTotVendas: TRLDBResult;
    rdrQtdProdutos: TRLDBResult;
    rdrICMS: TRLDBResult;
    rdrPIS: TRLDBResult;
    rdrCOFINS: TRLDBResult;
    rdrIPI: TRLDBResult;
    rdrII: TRLDBResult;
    rdrIS: TRLDBResult;
    rdrCBS: TRLDBResult;
    rdrIBSMun: TRLDBResult;
    rdrIBSUF: TRLDBResult;
    procedure FormCreate(Sender: TObject);
    procedure rdrQtdVendasCompute(Sender: TObject; var Value: Variant; var AText: string;
      var ComputeIt: Boolean);
  public
    class procedure Exibir;
  end;

var
  relTotaisSintetico: TrelTotaisSintetico;

implementation

uses
  udmdnfe;

{$R *.lfm}

const
  MSG_SEM_FILTRO = 'Aplique o filtro de período antes de gerar o relatório.';
  MSG_SEM_NOTAS = 'Nenhuma NFe no período filtrado.';
  MSG_PERIODO = 'Período: %s a %s';

{ TrelTotaisSintetico }

class procedure TrelTotaisSintetico.Exibir;
begin
  if not dmdNFe.qryNFeCab.Active then
  begin
    MessageDlg(MSG_SEM_FILTRO, mtInformation, [mbOK], 0);
    Exit;
  end;
  dmdNFe.AbrirTotaisSintetico;
  try
    if dmdNFe.qryTotaisSintetico.IsEmpty then
    begin
      MessageDlg(MSG_SEM_NOTAS, mtInformation, [mbOK], 0);
      Exit;
    end;
    relTotaisSintetico := TrelTotaisSintetico.Create(Application);
    try
      relTotaisSintetico.rlrTotaisSintetico.Preview;
    finally
      FreeAndNil(relTotaisSintetico);
    end;
  finally
    dmdNFe.qryTotaisSintetico.Close;
  end;
end;

procedure TrelTotaisSintetico.FormCreate(Sender: TObject);
begin
  rllPeriodo.Caption := Format(MSG_PERIODO, [
    DateToStr(dmdNFe.qryTotaisSintetico.ParamByName('DATA_INICIAL').AsDate),
    DateToStr(dmdNFe.qryTotaisSintetico.ParamByName('DATA_FINAL').AsDate)]);
end;

procedure TrelTotaisSintetico.rdrQtdVendasCompute(Sender: TObject; var Value: Variant;
  var AText: string; var ComputeIt: Boolean);
begin
  // COUNT(*) chega do Zeos como Int64, e o TRLDBResult só soma inteiros de 32 bits e ponto flutuante
  Value := Integer(Value);
end;

end.

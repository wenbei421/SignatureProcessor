unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,Vcl.Imaging.JPEG,
  SignatureHelper;

type
  TForm2 = class(TForm)
    img1: TImage;
    img2: TImage;
    btn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
var
  Bitmap: TBitmap;
begin
  try
    // ����ͼ��
    Bitmap := TSignatureHelper.LoadJpgToBitmap('.\small.jpg');
    img1.Picture.Assign(Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure TForm2.btn1Click(Sender: TObject);
var
  Bitmap: TBitmap;
begin
   try
     try
        Bitmap := TSignatureHelper.LoadJpgToBitmap('.\small.jpg');
        Bitmap := TSignatureHelper.ProcessSignature(Bitmap);
        img2.Picture.Assign(Bitmap);
        ShowMessage('处理完成');
     except
        on E: Exception do
          ShowMessage('处理失败: ' + E.Message);
     end;
   finally
      Bitmap.Free;
   end;
end;
end.

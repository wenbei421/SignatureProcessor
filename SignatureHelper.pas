unit SignatureHelper;

interface

uses
  System.SysUtils, System.Types, System.Math,
  Vcl.Graphics, Vcl.Imaging.JPEG;

type
  TSignatureHelper = class
  public
    class function ProcessSignature(const InputFile: string): TBitmap; overload;
    class function ProcessSignature(Bitmap: TBitmap): TBitmap; overload;
    class function LoadJpgToBitmap(const FileName: string): TBitmap;
  private
    class procedure FindSignatureArea(Bitmap: TBitmap; out SignatureRect: TRect);
    class procedure CropAndResize(Bitmap: TBitmap; SignatureRect: TRect; Width, Height: Integer);
    class procedure SaveBitmapAsJpg(Bitmap: TBitmap; const FileName: string; Quality: Integer = 75);
  end;

implementation

{ TSignatureHelper }

class function TSignatureHelper.ProcessSignature(const InputFile: string): TBitmap;
var
  Bitmap: TBitmap;
  SignatureRect: TRect;
begin
  Bitmap := LoadJpgToBitmap(InputFile);
  try
      Result := ProcessSignature(Bitmap);
  finally
    Bitmap.Free;
  end;
end;


class function TSignatureHelper.ProcessSignature(Bitmap: TBitmap): TBitmap;
var
  SignatureRect: TRect;
begin
  FindSignatureArea(Bitmap, SignatureRect);
  if (SignatureRect.Width > 0) and (SignatureRect.Height > 0) then
  begin
    CropAndResize(Bitmap, SignatureRect, Bitmap.Width, Bitmap.Height);
    Result := TBitmap.Create;
    Result.Assign(Bitmap);
  end
  else
    Result := Bitmap;
end;

class function TSignatureHelper.LoadJpgToBitmap(const FileName: string): TBitmap;
var
  Jpg: TJPEGImage;
begin
  if not FileExists(FileName) then
    raise Exception.Create('�ļ�������: ' + FileName);

  Jpg := TJPEGImage.Create;
  Result := TBitmap.Create;
  try
    Jpg.LoadFromFile(FileName);
    Result.Assign(Jpg);
  finally
    Jpg.Free;
  end;
end;

class procedure TSignatureHelper.FindSignatureArea(Bitmap: TBitmap; out SignatureRect: TRect);
var
  X, Y: Integer;
  Found: Boolean;
  BackgroundColor: TColor;
begin
  SignatureRect := Rect(0, 0, 0, 0);
  Found := False;
  BackgroundColor := Bitmap.Canvas.Pixels[0, 0];

  for Y := 0 to Bitmap.Height - 1 do
    for X := 0 to Bitmap.Width - 1 do
    begin
      if Bitmap.Canvas.Pixels[X, Y] <> BackgroundColor then
      begin
        if not Found then
        begin
          SignatureRect := Rect(X, Y, X, Y);
          Found := True;
        end
        else
        begin
          if X < SignatureRect.Left then SignatureRect.Left := X;
          if Y < SignatureRect.Top then SignatureRect.Top := Y;
          if X > SignatureRect.Right then SignatureRect.Right := X;
          if Y > SignatureRect.Bottom then SignatureRect.Bottom := Y;
        end;
      end;
    end;
end;

class procedure TSignatureHelper.CropAndResize(Bitmap: TBitmap; SignatureRect: TRect; Width, Height: Integer);
var
  Cropped, Resized: TBitmap;
  Ratio: Double;
  NewWidth, NewHeight: Integer;
begin
  if (SignatureRect.Width <= 0) or (SignatureRect.Height <= 0) then
    Exit;
  // ����ԭʼͼƬ������
  Ratio :=  Height / Width;
  NewWidth := SignatureRect.Width;
  NewHeight := Round(NewWidth * Ratio);
  if (NewHeight < SignatureRect.Height) then
  begin
      NewHeight :=  SignatureRect.Height;
      NewWidth :=  Round(SignatureRect.Height / Ratio);
  end;
  if( NewWidth > SignatureRect.Width) then
  begin
      SignatureRect.Left := SignatureRect.Left - Round((NewWidth - SignatureRect.Width)/2);
      SignatureRect.Right := SignatureRect.Right + Round((NewWidth - SignatureRect.Width)/2);
  end;
  if( NewHeight > SignatureRect.Height) then
  begin
      SignatureRect.Top := SignatureRect.Top - Round((NewHeight - SignatureRect.Height)/2);
      SignatureRect.Bottom := SignatureRect.Bottom + Round((NewHeight - SignatureRect.Height)/2);
  end;
  // �ü�ǩ������
  Cropped := TBitmap.Create;
  try
    Cropped.SetSize(NewWidth, NewHeight);
    Cropped.Canvas.CopyRect(Rect(0, 0, Cropped.Width, Cropped.Height), Bitmap.Canvas, SignatureRect);

    // �������ű���
    Ratio := Max(Width / Cropped.Width, Height / Cropped.Height);
    Resized := TBitmap.Create;
    try
      Resized.SetSize(Width, Height);
      Resized.Canvas.StretchDraw(Rect(0, 0, Width, Height), Cropped);
      Bitmap.Assign(Resized);
    finally
      Resized.Free;
    end;
  finally
    Cropped.Free;
  end;
end;

class procedure TSignatureHelper.SaveBitmapAsJpg(Bitmap: TBitmap; const FileName: string; Quality: Integer);
var
  Jpg: TJPEGImage;
begin
  Jpg := TJPEGImage.Create;
  try
    Jpg.Assign(Bitmap);
    Jpg.CompressionQuality := Quality;
    Jpg.SaveToFile(FileName);
  finally
    Jpg.Free;
  end;
end;

end.

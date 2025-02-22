# SignatureProcessor
## 电子签名自动放大裁剪处理程序
### 原始签名图片
![small](https://github.com/user-attachments/assets/c1846d24-82c7-476e-b3eb-61406f82a745)

### 处理后的签名图片
![normal](https://github.com/user-attachments/assets/0e90e142-2ebe-4b9e-a0a0-9fa507b79b49)

### 界面截图
![7e5a6a6cb03090770093c45f805ea778](https://github.com/user-attachments/assets/6ac14894-7495-49ad-b66f-1ea669ca0c46)

### 使用说明

#### 1. 引用单元
在需要使用的单元中添加 `SignatureHelper` 引用：

```delphi
uses
  SignatureHelper;
```

#### 2. 调用示例
```delphi
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
```

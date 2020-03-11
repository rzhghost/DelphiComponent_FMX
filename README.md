# DelphiComponent_FMX
自制常用FMX控件

TSyncWebImage  - 用于异步加载网络URL图片

使用例子:
```
procedure TForm1.Button1Click(Sender: TObject);
var swi:TSyncWebImage;
begin
  swi:=TSyncWebImage.create(self);
  swi.parent:=self;
  swi.Position.X := 0;
  swi.Position.Y:=0;
  swi.Width:=200;
  swi.Height:=200;
  //如需缩略图,设置下面两个属性
  swi.fitWidth:=100;
  swi.fitheight:=100;
  swi.URL := 'https://xxxxx.xxx.com/x.png';
  swi.Visible:=true;
end;
```

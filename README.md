# DelphiComponent_FMX
自制常用FMX控件

TSyncWebImage  - 用于异步加载网络URL图片

使用例子:
procedure TForm1.Button1Click(Sender: TObject);
var s:TSyncWebImage;
begin
  s:=TSyncWebImage.create(self);
  s.parent:=self;
  s.Position.X := 0;
  s.Position.Y:=0;
  s.Width:=200;
  s.Height:=200;
  //如需缩略图,设置下面两个属性
  s.fitWidth:=100;
  s.fitheight:=100;
  s.URL := 'https://xxxxx.xxx.com/x.png';
  s.Visible:=true;
end;

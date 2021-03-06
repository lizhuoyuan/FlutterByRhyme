import 'package:flutter/material.dart';
import 'package:flutterbyrhyme/design/entity/shop.dart';
import 'package:flutterbyrhyme/http/httpManager.dart' as httpManager;
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
const String kAddress='https://raw.githubusercontent.com/rhymelph/FlutterByRhyme/master/assets/shop.json';
//透明图片占位
final Uint8List kTransparentImage = new Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
]);

class ShopPage extends StatefulWidget {
  static const String routeName = 'design/ShopPage';

  @override
  _ShopPageState createState() => _ShopPageState();
}


class _ShopPageState extends State<ShopPage> {
  Widget body=Center(child: CircularProgressIndicator());

  @override
  void initState() {
    // TODO: implement initState
    initData();

    super.initState();
  }

  initData(){
    httpManager.get(url: kAddress,
    onSend: (){
      setState(() {
        body=Center(child: CircularProgressIndicator());
      });
    },
    onSuccess: (result){

      List<Shop> shopList=Shop.decode(result);
      setState(() {
        body=_ShopListBody(shopList);
      });
    },
    onError: (error){
      error.toString();
      setState(() {
        body=Center(
          child: FlatButton(onPressed: (){
            initData();
          }, child: Text('加载失败，点击重新加载')),
        );
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品列表'),
      ),
      body: body,
    );
  }
}

class _ShopListBody extends StatelessWidget {
  final List<Shop> shopList;

  const _ShopListBody(this.shopList);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints){
          double width=constraints.biggest.width/2;
          List<Shop> list1=[];
          List<Shop> list2=[];
          for(int i=0; i<shopList.length;i++){
            Shop shop =shopList[i];
            if(i%2==0){
              list1.add(shop);
            }else{
              list2.add(shop);
            }
          }
          return Row(
            children: <Widget>[
              Column(
                children: list1.map((shop){
                  return SizedBox(
                    width: width,
                    child: _ShopItem(shop: shop,width: width,),
                  );
                }).toList(),
              ),
              Column(
                children: list2.map((shop){
                  return SizedBox(
                    width: width,
                    child: _ShopItem(shop: shop,width: width,),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}


class _ShopItem extends StatelessWidget {
  final Shop shop;
  final double width;

  const _ShopItem({this.shop,this.width : 120.0});
  @override
  Widget build(BuildContext context) {
    return  Card(
      elevation: 4.0,
        child: RawMaterialButton(
          onPressed: () async {
            if (await canLaunch(shop.address)) {
            await launch(shop.address,
            forceSafariVC: true,
            forceWebView: false,
            statusBarBrightness: Brightness.light);
            }
          },
          padding: EdgeInsets.zero,
          splashColor: Theme.of(context).primaryColor.withOpacity(0.12),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: shop.image,fit: BoxFit.cover,
              height: width,width: width,),
              Row(
                children: <Widget>[
                  Expanded(child: Text(shop.name)),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(shop.nowPrice,style: Theme.of(context).textTheme.title,),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(shop.sourcePrice,style: Theme.of(context).textTheme.body1.copyWith(decoration: TextDecoration.lineThrough),),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(shop.sale,style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 12.0,),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

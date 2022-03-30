
import 'package:eyebody/data/data.dart';
import 'package:eyebody/data/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class EyeBodyAddPage extends StatefulWidget {
  final EyeBody eyeBody;

  EyeBodyAddPage({Key key, this.eyeBody}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _EyeBodyAddPageState();
  }
}

class _EyeBodyAddPageState extends State<EyeBodyAddPage> {

  TextEditingController weightController = TextEditingController();

  EyeBody get eyeBody => widget.eyeBody;

  @override
  void initState() {
    weightController.text = eyeBody.weight.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(child: Text("저장", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              eyeBody.weight = int.tryParse(weightController.text) ?? 0;

              final dbHelper = DatabaseHelper.instance;
              await dbHelper.insertEyeBody(eyeBody);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (ctx, idx){
            if(idx == 0){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Text("오늘의 눈바디를 기록해주세요", style: TextStyle(fontSize: 20),),
              );
            }
            else if(idx == 1){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("몸무게", style: TextStyle(fontSize: 16),),
                    Container(child: TextField(
                      controller: weightController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                    ), width: 100,)
                  ],
                ),
              );
            }
            else if(idx == 2){
              return Container(
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                width: 300,
                height: 300,
                child: Container(child: Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    child: AspectRatio(child: eyeBody.image.isEmpty ? Image.asset("assets/img/eyeBody.png") :
                    AssetThumb(asset: Asset(eyeBody.image, "eyeBody.png", 0, 0), width: 300, height: 300),
                      aspectRatio: 1,
                    ),
                    onTap: (){
                      selectImage();
                    },
                  ),
                )),
              );
            }
            return Container();
          },
          itemCount: 5,
        ),
      ),
    );
  }

  Future<void> selectImage() async {
    final __img = await MultiImagePicker.pickImages(maxImages: 1, enableCamera: true);

    if(__img.length < 1){
      return;
    }
    setState(() {
      eyeBody.image = __img.first.identifier;
    });
  }
}

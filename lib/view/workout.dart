
import 'package:eyebody/data/data.dart';
import 'package:eyebody/data/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class WorkoutAddPage extends StatefulWidget {
  final Workout workout;

  WorkoutAddPage({Key key, this.workout}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _WorkoutAddPageState();
  }
}

class _WorkoutAddPageState extends State<WorkoutAddPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController memoController = TextEditingController();

  Workout get workout => widget.workout;

  @override
  void initState() {
    timeController.text = workout.time.toString();
    memoController.text = workout.memo;
    nameController.text = workout.name;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(child: Text("저장", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              workout.memo = memoController.text;
              workout.name = nameController.text;
              workout.time = int.tryParse(timeController.text) ?? 0;

              final dbHelper = DatabaseHelper.instance;
              await dbHelper.insertWorkout(workout);
              Navigator.of(context).pop();
            },
          )],
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (ctx, idx){
            if(idx == 0){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("어떤 운동을 하셨나요?", style: TextStyle(fontSize: 20),),
                    TextField(
                      controller: nameController,
                    )
                  ],
                ),
              );
            }
            else if(idx == 1){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("운동시간", style: TextStyle(fontSize: 16),),
                    Container(child: TextField(
                      controller: timeController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                    ), width: 100,)
                  ],
                ),
              );
            }else if(idx == 2){
              return Container(
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                width: 300,
                height: 300,
                child: Container(child: Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    child: AspectRatio(child: workout.image.isEmpty ? Image.asset("assets/img/workout.png") :
                    AssetThumb(asset: Asset(workout.image, "food.png", 0, 0), width: 300, height: 300),
                      aspectRatio: 1,
                    ),
                    onTap: (){
                      selectImage();
                    },
                  ),
                )),
              );
            }
            else if(idx == 3){
              return Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("메모", style: TextStyle(fontSize: 16),),
                    Container(height: 12,),
                    TextField(
                      maxLines: 10,
                      minLines: 10,
                      keyboardType: TextInputType.multiline,
                      controller: memoController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          )
                      ),
                    )
                  ],
                ),
              );
            }
            return Container();
          },
          itemCount: 4,
        ),
      )
      ,
    );
  }

  Future<void> selectImage() async {
    final __img = await MultiImagePicker.pickImages(maxImages: 1, enableCamera: true);

    if(__img.length < 1){
      return;
    }
    setState(() {
      workout.image = __img.first.identifier;
    });
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = "https://owlbot.info/api/v4/dictionary/owl -s | json_pp";
  String token = "4d7553c550dd15bb27fbbb7fb6556d6e7d677ff2";

  TextEditingController textEditingController = TextEditingController();

  late StreamController streamController;
  late Stream stream;

  late Timer _debounce;

  searchText() async{
    if(textEditingController.text.isEmpty)
    {
        streamController.add(null);
        return;
    }
    streamController.add('waiting');
    Response response = await get(
      (url + textEditingController.text.trim()) as Uri,
      headers: {'Authorization': "Token $token"});
    streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamController = StreamController();
    stream = streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Dictionary",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 12,bottom: 11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      onChanged: (String text){
                        if(_debounce?.isActive ?? false) _debounce.cancel();
                        _debounce = Timer(const Duration(milliseconds: 1000), () {
                          searchText();
                        });
                      },
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: "Search for a word",
                        contentPadding: const EdgeInsets.only(left: 24),
                        border: InputBorder.none,
                      ),
                    ),
                  )
              ),
              IconButton(
                  onPressed: (){
                    searchText();
                  },
                  icon: Icon(Icons.search,color: Colors.white,size: 25,)
              ),
            ],
          ),
        ),
      ),

      body: Container(
        margin: const EdgeInsets.all(8),
        child: StreamBuilder(
          builder: (BuildContext context,AsyncSnapshot snapshot){
            if(snapshot.data == null)
            {
              return const Center(
                child: Text("Enter a word"),
              );
            }
            if(snapshot.data == 'waiting'){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data['definitions'].length,
                itemBuilder: (BuildContext context, int index){
                    return ListBody(
                      children: [
                        Container(
                          color: Colors.grey.shade300,
                          child: ListTile(
                            leading: snapshot.data["definitions"][index]['image_url'] == null ? null : CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data['definitions'][index]["image_url"]),
                            ),
                            title: Text(textEditingController.text.trim()+"(" + snapshot.data["definitions"][index]["type"] + ")"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            snapshot.data['definitions'][index]["definition"]
                          ),
                        )
                      ],
                    );
                }
            );
          },
          stream: stream,
        ),
      ),
    );
  }
}
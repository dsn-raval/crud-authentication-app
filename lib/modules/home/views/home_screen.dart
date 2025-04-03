import 'package:crud_authentication_task/modules/home/providers/api_provider.dart';
import 'package:crud_authentication_task/modules/auth/providers/auth_provider.dart';
import 'package:crud_authentication_task/modules/settings/views/settings_scrren.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  @override
  void initState() {
    Future.microtask(() {
      Provider.of<ApiProvider>(context, listen: false).fetchData();
      Provider.of<AuthProvider>(context, listen: false).fetchUserRole();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      Provider.of<ApiProvider>(context, listen: false).fetchData();
      Provider.of<AuthProvider>(context, listen: false).fetchUserRole();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    bool isAdmin = authProvider.role == "admin";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: Text("H O M E", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          apiProvider.datas.isEmpty
              ? Expanded(flex: 10, child: Center(child: Text("No data...")))
              : Expanded(
                child: Consumer<ApiProvider>(
                  builder: (context, api, child) {
                    return api.datas.isEmpty
                        ? Center(child: Text("No Data"))
                        : ListView.builder(
                          itemCount: api.datas.length,
                          itemBuilder: (context, index) {
                            var data = api.datas[index];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: Card(
                                color: Colors.white,
                                child: ListTile(
                                  title: Text(data["title"]),
                                  subtitle: Text(data["body"]),
                                  trailing: IgnorePointer(
                                    ignoring: isAdmin,
                                    child: Opacity(
                                      opacity: isAdmin ? 1 : 0.5,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.indigo,
                                            radius: 20,
                                            child: InkWell(
                                              onTap: () {
                                                _titleController.text =
                                                    data["title"];
                                                _subtitleController.text =
                                                    data["body"];
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return _addEditDialogFiled(
                                                      text: "Update",
                                                      title: "Update Data",
                                                      onTap: () async {
                                                        await apiProvider
                                                            .updateData(
                                                              data["id"],
                                                              _titleController
                                                                  .text,
                                                              _subtitleController
                                                                  .text,
                                                            )
                                                            .then((value) {
                                                              _titleController
                                                                  .clear();
                                                              _subtitleController
                                                                  .clear();
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            });
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          CircleAvatar(
                                            backgroundColor: Colors.red,
                                            radius: 20,
                                            child: InkWell(
                                              onTap: () async {
                                                await apiProvider
                                                    .deleteData(data["id"])
                                                    .then((value) {
                                                      setState(() {
                                                        apiProvider.fetchData();
                                                      });
                                                    });
                                              },
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                  },
                ),
              ),
        ],
      ),
      floatingActionButton: IgnorePointer(
        ignoring: !isAdmin,
        child: Opacity(
          opacity: isAdmin ? 1 : 0.5,
          child: FloatingActionButton(
            backgroundColor: Colors.lightBlue,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return _addEditDialogFiled(
                    title: "Create Data",
                    text: "Add",
                    onTap: () async {
                      await apiProvider
                          .addData(
                            _titleController.text,
                            _subtitleController.text,
                          )
                          .then((value) {
                            _titleController.clear();
                            _subtitleController.clear();
                            Navigator.pop(context);
                          });
                    },
                  );
                },
              );
            },
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _addEditDialogFiled({
    required String text,
    required String title,
    required Function() onTap,
  }) {
    return AlertDialog(
      title: Text(title),
      actions: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: "Title",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _subtitleController,
          decoration: InputDecoration(
            labelText: "Subtitle",
            border: OutlineInputBorder(),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(text)),
      ],
    );
  }
}

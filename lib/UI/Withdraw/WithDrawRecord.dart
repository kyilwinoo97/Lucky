import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lucky/Constants/Constants.dart';
import 'package:lucky/Data/Database/database.dart';
import 'package:lucky/Data/Result.dart';
import 'package:lucky/Repository/TransactionViewModel.dart';
import 'package:lucky/UI/Transactions/TransactionDetail.dart';
import 'package:lucky/UI/Transactions/TransactionItem.dart';
import 'package:lucky/UI/Widgets/CustomFloatingButton.dart';
import 'package:lucky/UI/Widgets/LuckyAppBar.dart';
import 'package:lucky/UI/Widgets/LuckyFloatingActionButton.dart';
import 'package:lucky/UI/Withdraw/Withdraw.dart';
import 'package:lucky/Utils/Colors.dart';
import 'package:lucky/Utils/Utils.dart';
import 'package:lucky/common/serviceLocator.dart';

class WithDrawRecord extends StatefulWidget{
  @override
  _WithdrawRecordState createState() => _WithdrawRecordState();
}

class _WithdrawRecordState extends State<WithDrawRecord> {
  final TransactionViewModel model = serviceLocator<TransactionViewModel>();

  List<Transaction> transactionList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: luckyAppbar(
          context: context,
          title: "Withdraw",
          actions: [
        IconButton(
            onPressed: () {
              setState(() {
                showSearch(context: context, delegate: DataSearch(transactionList));
              });
            },
            icon: Icon(
              Icons.search,
              size: 25.0,
              color: Colors.white,
            )),
      ]
        ),
      body: StreamBuilder(
          stream: model.getTransactionByType(context, Constants.WITHDRAW_TYPE),
          builder: (context, AsyncSnapshot<List<Transaction>> snapshot) {
            transactionList = snapshot.data ?? [];
            return buildBody(transactionList);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: LuckyFloatingActionButton(
        onTap: () async{
      var result = await  Navigator.push(context, MaterialPageRoute(
              builder: (context) => Withdraw()));
        },
      ),
    );

  }
  buildBody(List<Transaction> transactionList) {
    final Orientation orientation = MediaQuery
        .of(context)
        .orientation;
    return transactionList.length > 0
        ? (orientation == Orientation.landscape
        ? buildLandscapeLayout(
      transactionList,
    )
        : buildTransferRecord(
      transactionList,
    ))
        : Utils.buildEmptyView(
        context: context,
        icon: LineAwesomeIcons.crying_face,
        title: "Empty Withdraw");
  }

  buildLandscapeLayout(List<Transaction> transactionList) {
    return ListView.builder(
      itemCount: transactionList.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () {
          Utils.checkInternetConnection(context).then((value) =>
          {
          if(!value){
          ScaffoldMessenger.of(context).showSnackBar(Utils.showSnackBar()),
          } else
          {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TransactionDetail(transactionList[index]))),
        }
          });

              },
        child: Container(
          width: 20,
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actions: <Widget>[
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => {
                  deleteTransaction(transactionList[index]),
                },
              ),
            ],
            child: TransactionItem(
              transaction: transactionList[index],
            ),
          ),
        ),
      ),
    );

  }

  buildTransferRecord(List<Transaction> transactionList) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: ListView.builder(
        itemCount: transactionList.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            Utils.checkInternetConnection(context).then((value) =>
            {
              if(!value){
                ScaffoldMessenger.of(context).showSnackBar(Utils.showSnackBar()),
              } else
                {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => TransactionDetail(transactionList[index]))),
                }
            });
          },
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actions: <Widget>[
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => {
                  deleteTransaction(transactionList[index]),
                },
              ),
            ],
            child: TransactionItem(
              transaction: transactionList[index],
            ),
          ),
        ),
      ),
    );

  }

  deleteTransaction(Transaction transaction) {
    Utils.confirmDialog(
        context, "Confirm", "Are you sure want to delete.")
        .then((value) {
      if (value) {
         model.deleteTransaction(context, transaction);
      }
    });
  }
}
class DataSearch extends SearchDelegate<String> {

  final List<Transaction> transactionList;

  DataSearch(this.transactionList);

  // @override
  // ThemeData appBarTheme(BuildContext context) {
  //   return ThemeData(
  //     primaryColor: LuckyColors.splashScreenColors,
  //   );
  // }

  @override
  List<Widget> buildActions(BuildContext context) {
    //Actions for app bar
    return [IconButton(icon: Icon(Icons.clear), onPressed: () {
      query = '';
    })];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icon on the left of the app bar
    return IconButton(
        icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, "");
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on the selection
    final suggestionList = query.isEmpty
        ? transactionList
        : transactionList.where((p) => p.toCustomerName.startsWith(RegExp(query, caseSensitive: false))).toList();
    if(suggestionList.length > 0){
      return ListView.builder(itemBuilder: (context, index) => ListTile(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => TransactionDetail(suggestionList[index])));
        },
        trailing: Icon(Icons.arrow_forward_ios_outlined,size: 18.0,),
        title: Text(suggestionList[index].toCustomerName,style: TextStyle(
            fontSize: 15.0
        ),),
      ),
        itemCount: suggestionList.length,
      );
    }else{
      return Center(
        child: Text("No result found!"),
      );
    }

}

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? transactionList
        : transactionList.where((p) => p.toCustomerName.startsWith(RegExp(query, caseSensitive: false))).toList();


    return ListView.builder(itemBuilder: (context, index) => ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => TransactionDetail(suggestionList[index])));
      },
      trailing: Icon(Icons.arrow_forward_ios_outlined,size: 18.0,),
      title: RichText(
        text: TextSpan(
            text: suggestionList[index].toCustomerName.substring(0, query.length),
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: suggestionList[index].toCustomerName.substring(query.length),
                  style: TextStyle(color: Colors.grey))
            ]),
      ),
    ),
      itemCount: suggestionList.length,
    );
  }
}
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucky/Constants/Constants.dart';
import 'package:lucky/Data/SharedPref/basicInfo.dart';
import 'package:lucky/Data/UserInfo.dart';
import 'package:lucky/Repository/AgentViewModel.dart';
import 'package:lucky/Repository/HomeViewModel.dart';
import 'package:lucky/UI/Agent/Agent.dart';
import 'package:lucky/UI/Analytics/Analytics.dart';
import 'package:lucky/UI/Bill/BillRecord.dart';
import 'package:lucky/UI/Deposite/DepositeRecord.dart';
import 'package:lucky/UI/History/HistoryTab.dart';
import 'package:lucky/UI/Profile/Profile.dart';
import 'package:lucky/UI/Transfer/TransferRecord.dart';
import 'package:lucky/UI/Transfer/TransferTab.dart';
import 'package:lucky/UI/User/UserScreens.dart';
import 'package:lucky/UI/Widgets/ButtonWidgets.dart';
import 'package:lucky/UI/Widgets/HomeScreenTopWidget.dart';
import 'package:lucky/UI/Withdraw/WithDrawRecord.dart';
import 'package:lucky/Utils/Utils.dart';
import 'package:lucky/common/serviceLocator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

// ignore: camel_case_types
class _HomeState extends State<Home> {
  final HomeViewModel model = serviceLocator<HomeViewModel>();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late UserInfo userInfo;

  @override
  void initState() {
    super.initState();
    model.getAllBalance(context);
    getUserInfo();
  }
  void getUserInfo() async{
    UserInfo userInfo =await basicInfo.getUserInfo();
    if(userInfo != null){
      setState(() {
        this.userInfo =  userInfo;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    var depositWidget = ButtonWidgets(
      icon: Icon(Icons.account_balance),
      onTap: () {
       Navigator.push(
            context, MaterialPageRoute(builder: (context) => DepositRecord())).then((value) => model.getAllBalance(context));
      },
      text: "Deposit",
    );
    var withdrawWidget = ButtonWidgets(
      icon: Icon(Icons.credit_card),
      onTap: (){
       Navigator.push(
            context, MaterialPageRoute(builder: (context) => WithDrawRecord())).then((value) => model.getAllBalance(context));
      },
      text: "Withdraw",
    );
    var transferWidget = ButtonWidgets(
      icon: Icon(Icons.send),
      onTap: () {
       Navigator.push(
            context, MaterialPageRoute(builder: (context) => TransferTab())).then((value) => model.getAllBalance(context));
      },
      text: "Transfer",
    );
    var billTopUpWidget = ButtonWidgets(
      icon: Icon(Icons.villa),
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BillRecord())).then((value) => model.getAllBalance(context));
      },
      text: "Bill",
    );
    var analyticsWidget = ButtonWidgets(
      icon: Icon(Icons.insert_chart),
      onTap: () {
        if(userInfo.userType.trim() == Constants.AdminUserType){
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Analytics()));
        }else{
          ScaffoldMessenger.of(context).showSnackBar(Utils.showSnackBar(text: "Permission denied!"));
        }
      },
      text: "Analytics",
    );
    var historyWidget = ButtonWidgets(
      icon: Icon(Icons.history),
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HistoryTab()));
      },
      text: "History",
    );
    var usersWidget = ButtonWidgets(
      icon: Icon(Icons.people),
      onTap: () {
        if(userInfo.userType.trim() == Constants.AdminUserType){
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen()));
        }else{
          ScaffoldMessenger.of(context).showSnackBar(Utils.showSnackBar(text: "Permission denied!"));
        }
      },
      text: "Users",
    );
    var profileWidget = ButtonWidgets(
      icon: Icon(Icons.account_circle_sharp),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
      },
      text: "Profile",
    );
    var agentWidget = ButtonWidgets(
      icon: Icon(Icons.real_estate_agent),
      onTap: () {
       Navigator.push(
            context, MaterialPageRoute(builder: (context) => Agent())).then((value) =>
         model.getAllBalance(context));

      },
      text: "Agent",
    );

    return ChangeNotifierProvider<HomeViewModel>(
      create: (context) => model,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Lucky",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: Color.fromRGBO(244, 244, 244, 1),
          body: SmartRefresher(
              onRefresh: _refresh,
              controller: _refreshController,

              child: MediaQuery.of(context).orientation == Orientation.portrait
                  ? buildPortraitView(Consumer<HomeViewModel>(
                      builder: (context, model, child) {
                        return HomeScreenTopWidget(
                          cash: model.totalCash,
                          eMoney: model.totalEmoney,
                        );
                      },
                    ),
                      depositWidget,
                      withdrawWidget,
                      transferWidget,
                      billTopUpWidget,
                      agentWidget,
                      analyticsWidget,
                      historyWidget,
                      usersWidget,
                      profileWidget)
                  : buildLandscapeView(Consumer<HomeViewModel>(
                      builder: (context, model, child) {
                        return HomeScreenTopWidget(
                          cash: model.totalCash,
                          eMoney: model.totalEmoney,
                        );
                      },
                    ),
                      depositWidget,
                      withdrawWidget,
                      transferWidget,
                      // bankTransferWidget,
                      billTopUpWidget,
                      agentWidget,
                      analyticsWidget,
                      historyWidget,
                      usersWidget,
                      profileWidget))
          //   ],
          // ),
          // ),
          ),
    );
  }

  buildPortraitView(
    Widget topSection,
    Widget depositWidget,
    Widget withdrawWidget,
    Widget transferWidget,
    Widget bankTransferWidget,
    Widget billTopUpWidget,
    Widget analyticsWidget,
    Widget historyWidget,
    Widget usersWidget,
    Widget profileWidget,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          topSection,
          Container(
            padding: EdgeInsets.all(14.0),
            width: double.infinity,
            child: Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 40.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        depositWidget,
                        withdrawWidget,
                        transferWidget,
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        bankTransferWidget,
                        billTopUpWidget,
                        analyticsWidget,
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 40,
                    ).copyWith(
                      bottom: 40,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        historyWidget,
                        usersWidget,
                        profileWidget,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    model.getAllBalance(context);
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  buildLandscapeView(
      Widget topSection,
      ButtonWidgets depositWidget,
      ButtonWidgets withdrawWidget,
      ButtonWidgets transferWidget,
      ButtonWidgets billTopUpWidget,
      ButtonWidgets agentWidget,
      ButtonWidgets analyticsWidget,
      ButtonWidgets historyWidget,
      ButtonWidgets usersWidget,
      ButtonWidgets profileWidget) {
    return ListView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              topSection,
              Container(
                padding: EdgeInsets.only(left: 32,right: 32,bottom: 10),
                width: double.infinity,
                child: Card(
                  elevation: 20,
                  shadowColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      // side: BorderSide(width: 5, color: Colors.green)
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 20.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            depositWidget,
                            withdrawWidget,
                            transferWidget,
                            billTopUpWidget,
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            agentWidget,
                            analyticsWidget,
                            historyWidget,
                            usersWidget,
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 20,
                        ).copyWith(
                          bottom: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            profileWidget,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
    );
  }
}

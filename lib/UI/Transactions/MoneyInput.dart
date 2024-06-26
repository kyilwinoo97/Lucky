import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lucky/Constants/Constants.dart';
import 'package:lucky/Data/Database/database.dart';
import 'package:lucky/Repository/AgentViewModel.dart';
import 'package:lucky/Repository/MoneyInputViewModel.dart';
import 'package:lucky/UI/Widgets/CustomButton.dart';
import 'package:lucky/UI/Widgets/CustomTextInput.dart';
import 'package:lucky/UI/Widgets/LuckyAppBar.dart';
import 'package:lucky/UI/Widgets/Wrapper.dart';
import 'package:lucky/Utils/Colors.dart';
import 'package:lucky/Utils/Utils.dart';
import 'package:lucky/Utils/styles.dart';
import 'package:lucky/common/serviceLocator.dart';
import 'package:provider/provider.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:responsive_widgets/responsive_widgets.dart';

class MoneyInput extends StatefulWidget {
  final String name;
  final int index;

  const MoneyInput({
    Key? key,
    required this.name,
    required this.index,
  }) : super(key: key);

  @override
  _MoneyInputState createState() => _MoneyInputState();
}

class _MoneyInputState extends State<MoneyInput> {
  late BalanceDao balanceDao;

  late TextEditingController _cashInputController;
  late TextEditingController _eMoneyInputController;
  late TextEditingController _reasonInputController;
  late Wrapper _cashInputErrMessage;
  late Wrapper _eMoneyInputErrMessage;
  final List<String> imageList = [
    "assets/images/wave(512).jpg",
    "assets/images/kbzpayicon.jpg",
    "assets/images/cbpay.jpg",
    "assets/images/truemoney.jpg"
  ];
  final MoneyInputViewModel model = serviceLocator<MoneyInputViewModel>();
  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
    this._cashInputController = new TextEditingController(text: "");
    this._eMoneyInputController = new TextEditingController(text: "");
    this._reasonInputController = new TextEditingController(text: "");
    this._cashInputErrMessage = new Wrapper("");
    this._eMoneyInputErrMessage = new Wrapper("");
    balanceDao = Provider.of<BalanceDao>(context, listen: false);
    model.getBalanceByAgentId(widget.name, context);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      ResponsiveWidgets.init(
        context,
        height: 800,
        width: 480,
        allowFontScaling: true,
      );
    } else {
      ResponsiveWidgets.init(
        context,
        width: 800,
        height: 480,
        allowFontScaling: true,
      );
    }
    var submitBtn = SolidGreenButton(
      title: "Add",
      clickHandler: () async {
        if (checkValid()) {
          saveData();
          Utils.hideKeyboard(context);
        }
      },
    );
    var cancelButton = OutlineGreenElevatedButton(
      title: "Reduce",
      clickHandler: () async {
        if (checkReduceAmountValid()) {
          saveReduceData();
          Utils.hideKeyboard(context);
        }
      },
    );
    var eMoneyInput = CustomTextInput(
      errorMessage: _eMoneyInputErrMessage.value,
      controller: this._eMoneyInputController,
      isRequired: true,
      inputType: TextInputType.number,
      label: "E-Money Amount",
      hintText: "Enter E-Money Amount",
      leadingIcon: Icon(
        LineAwesomeIcons.wallet,
        size: 25.0,
      ),
    );
    // var moneyHistory = buildMoneyInputRecordSection();
    var cashInput = CustomTextInput(
      errorMessage: this._cashInputErrMessage.value,
      controller: this._cashInputController,
      isRequired: true,
      inputType: TextInputType.number,
      label: "Cash Amount",
      hintText: "Enter Cash Amount",
      leadingIcon: Icon(
        LineAwesomeIcons.alternate_wavy_money_bill,
        size: 25.0,
      ),
    );
    var reasonInput = CustomTextInput(
      errorMessage: "",
      controller: this._reasonInputController,
      isRequired: false,
      inputType: TextInputType.text,
      label: "Reason",
      hintText: "Enter Reason",
      leadingIcon: Icon(
        LineAwesomeIcons.sticky_note,
        size: 25.0,
      ),
    );

    var leading = InkWell(
      onTap: () {
        Navigator.of(context).pop(isUpdated);
      },
      child: Icon(
        Icons.arrow_back,
        size: 25.0,
        color: Colors.white,
      ),
    );
    return ChangeNotifierProvider<MoneyInputViewModel>(
      create: (context) => model,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(isUpdated);
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: luckyAppbar(
            title: "Set Money",
            context: context,
            leading: leading,
          ),
          body: MediaQuery.of(context).orientation == Orientation.portrait
              ? buildPortraitView(
                  submitBtn,
                  eMoneyInput,
                  cashInput,
                  reasonInput,
                  cancelButton,
                )
              : buildLandscapeView(
                  submitBtn,
                  eMoneyInput,
                  cashInput,
                  reasonInput,
                  cancelButton,
                ),
        ),
      ),
    );
  }

  buildPortraitView(
      SolidGreenButton submitBtn,
      CustomTextInput eMoneyInput,
      CustomTextInput cashInput,
      CustomTextInput reasonInput,
      OutlineGreenElevatedButton reduceAmountBtn) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image(
                  image: AssetImage(imageList[widget.index]),
                  height: 150,
                  width: 150,
                ),
              ),
            ),
            Consumer<MoneyInputViewModel>(
              builder: (context, model, child) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "Remaining Cash : ",
                            style: formLabelTextStyle.copyWith(fontSize: 15.0),
                          ),
                          Text(
                            model.cash.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "Remaining E-Money : ",
                            style: formLabelTextStyle.copyWith(fontSize: 14.0),
                          ),
                          Text(
                            model.eMoney.toString(),
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: cashInput,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: eMoneyInput,
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: reasonInput),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: submitBtn,
                    ),
                  ),
                  Expanded(
                    child: reduceAmountBtn,
                  ),
                ],
              ),
            ),

            // Expanded(
            //   child: moneyInputHistory,
            // )
          ],
        ),
      ),
    );
  }

  buildLandscapeView(
      SolidGreenButton submitBtn,
      CustomTextInput eMoneyInput,
      CustomTextInput cashInput,
      CustomTextInput reasonInput,
      OutlineGreenElevatedButton reduceAmountBtn) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Consumer<MoneyInputViewModel>(
                    builder: (context, model, child) {
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Row(
                              children: [
                                Text(
                                  "Remaining Cash : ",
                                  style: formLabelTextStyle.copyWith(
                                      fontSize: 18.0),
                                ),
                                Text(
                                  model.cash.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  "Remaining E-Money : ",
                                  style: formLabelTextStyle.copyWith(
                                      fontSize: 18.0),
                                ),
                                Text(
                                  model.eMoney.toString(),
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: cashInput),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: eMoneyInput),

                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: reasonInput),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: submitBtn,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: reduceAmountBtn,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Expanded(
            //   child: Padding(
            //     padding: EdgeInsets.only(top: 20.0),
            //     child: moneyInputHistory,
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  bool checkValid() {
    bool isValid = true;

    String cashErrorMsg = "";
    String eMoneyErrorMsg = "";
    if (this._cashInputController.text.trim().isNotEmpty) {
      double cash = double.parse(this._cashInputController.text.trim());
      if (cash < 1) {
        cashErrorMsg = "Invalid";
        isValid = false;
      }
    }
    if (_eMoneyInputController.text.trim().isNotEmpty) {
      double Emoney = double.parse(this._eMoneyInputController.text.trim());
      if (Emoney < 1) {
        eMoneyErrorMsg = "Invalid";
        isValid = false;
      }
    }
    if (_cashInputController.text.trim().isEmpty &&
        _eMoneyInputController.text.trim().isEmpty) {
      isValid = false;
      eMoneyErrorMsg = "Required";
      cashErrorMsg = "Required";
    }

    setState(() {
      this._cashInputErrMessage.value = cashErrorMsg;
      this._eMoneyInputErrMessage.value = eMoneyErrorMsg;
    });
    return isValid;
  }

  void saveData() async {
    var result;
    double cash = this._cashInputController.text.trim().isNotEmpty
        ? double.parse(this._cashInputController.text.trim())
        : 0.0;
    double eMoney = this._eMoneyInputController.text.trim().isNotEmpty
        ? double.parse(this._eMoneyInputController.text.trim())
        : 0.0;
    BalanceData balanceData =
        await balanceDao.getBalanceViaAgentId(this.widget.name);

    OpeningClosingData openingClosingData =
    await model.getOpeningClosingByAgentAndDate(
        this.widget.name, Utils.getCurrentDate());
    if(openingClosingData != null){
      if(openingClosingData.closingEMoney! > 0.0|| openingClosingData.closingCash! > 0.0){
        Utils.errorDialog(context, "Balance is close for today");
        return;
      }
        await model.updateOpenClosingBalance(OpeningClosingData(
            id: openingClosingData.id,
            openingCash: openingClosingData.openingCash + cash,
            openingEMoney: openingClosingData.openingEMoney + eMoney,
            closingCash: openingClosingData.closingCash,
            closingEMoney: openingClosingData.closingEMoney,
            date: Utils.getCurrentDate(),
            agent: this.widget.name));

    } else {
      await model.insertOpenClosingBalance(
          context,
          OpeningClosingData(
              openingCash: cash,
              openingEMoney: eMoney,
              date: Utils.getCurrentDate(),
              agent: this.widget.name));
    }
    result = await model.insertBalanceRecords(
        context,
        BalanceInputRecord(
            agent: this.widget.name,
            date: Utils.getCurrentDate(),
            eMoney: eMoney,
            cash: cash,
            inputType: Constants.MoneyInputAdd,
            reason: _reasonInputController.text));
    if (balanceData != null) {
      if (balanceData.date == Utils.getCurrentDate()) {
        cash += balanceData.cash;
        eMoney += balanceData.eMoney;
      }
      result = await model.updateBalance(
        BalanceData(
            id: balanceData.id,
            cash: cash,
            eMoney: eMoney,
            date: Utils.getCurrentDate(),
            agent: this.widget.name),
      );
    } else {
      result = await model.insertBalance(
        BalanceData(
            cash: cash,
            eMoney: eMoney,
            date: Utils.getCurrentDate(),
            agent: this.widget.name),
      );
    }
    isUpdated = result;
    if (result) {
      clearInputs();
      Utils.successDialog(context, "Success!", "Successfully Added");
    } else {
      Utils.errorDialog(context, "Something went wrong!");
    }
  }

  void clearInputs() {
    setState(() {
      this._cashInputController.text = "";
      this._cashInputErrMessage.value = "";
      this._eMoneyInputErrMessage.value = "";
      this._eMoneyInputController.text = "";
      this._reasonInputController.text = "";
    });
  }

  bool checkReduceAmountValid() {
    bool isValid = true;
    String cashErrorMsg = "";
    String eMoneyErrorMsg = "";
    if (this._cashInputController.text.trim().isNotEmpty) {
      double cash = double.parse(this._cashInputController.text.trim());
      if (cash < 1) {
        cashErrorMsg = "Invalid";
        isValid = false;
      } else if (cash > model.cash) {
        cashErrorMsg = "Exceed max amount";
        isValid = false;
      }
    }
    if (_eMoneyInputController.text.trim().isNotEmpty) {
      double Emoney = double.parse(this._eMoneyInputController.text.trim());
      if (Emoney < 1) {
        eMoneyErrorMsg = "Invalid";
        isValid = false;
      } else if (Emoney > model.eMoney) {
        eMoneyErrorMsg = "Exceed max amount";
        isValid = false;
      }
    }
    if (_cashInputController.text.trim().isEmpty &&
        _eMoneyInputController.text.trim().isEmpty) {
      isValid = false;
      eMoneyErrorMsg = "Required";
      cashErrorMsg = "Required";
    }

    setState(() {
      this._cashInputErrMessage.value = cashErrorMsg;
      this._eMoneyInputErrMessage.value = eMoneyErrorMsg;
    });
    return isValid;
  }

  void saveReduceData() async {
    var result;
    double cash = this._cashInputController.text.trim().isNotEmpty
        ? double.parse(this._cashInputController.text.trim())
        : 0.0;
    double eMoney = this._eMoneyInputController.text.trim().isNotEmpty
        ? double.parse(this._eMoneyInputController.text.trim())
        : 0.0;
    BalanceData balanceData =
        await balanceDao.getBalanceViaAgentId(this.widget.name);
    double reducedEMoney = balanceData.eMoney - eMoney;
    double reducedCash = balanceData.cash - cash;
   result = await model.insertBalanceRecords(
        context,
        BalanceInputRecord(
            agent: this.widget.name,
            date: Utils.getCurrentDate(),
            eMoney: eMoney,
            cash: cash,
            inputType: Constants.MoneyInputReduce,
            reason: _reasonInputController.text));
    result = await model.updateBalance(
      BalanceData(
          id: balanceData.id,
          cash: reducedCash,
          eMoney: reducedEMoney,
          date: Utils.getCurrentDate(),
          agent: this.widget.name),
    );
    isUpdated = result;
    if (result) {
      clearInputs();
      Utils.successDialog(context, "Success!", "Successfully Reduce.");
    } else {
      Utils.errorDialog(context, "Something went wrong!");
    }
  }
}

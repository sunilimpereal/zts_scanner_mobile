import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:zts_scanner_mobile/dashboard/data/model/ticket_detail.dart';
import 'package:zts_scanner_mobile/dashboard/data/repository/scanner_repository.dart';
import 'package:zts_scanner_mobile/dashboard/screen/dashboard_home.dart';
import 'package:zts_scanner_mobile/utils/methods.dart';

class PostTicketScanScreen extends StatefulWidget {
  final TicketDetail ticketDetail;
  const PostTicketScanScreen({Key? key, required this.ticketDetail}) : super(key: key);

  @override
  _PostTicketScanScreenState createState() => _PostTicketScanScreenState();
}

class _PostTicketScanScreenState extends State<PostTicketScanScreen> {
  late String qrCode = "";
  late bool loading = false;
  @override
  void initState() {
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   Future.delayed(const Duration(seconds: 15)).then((value) {
    //     Navigator.pop(context);
    //   });
    // });

    super.initState();
  }

  clear() {
    setState(() {
      loading = false;
      qrCode = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (event) async {
            // log("key: ${event.character.toString()}");

            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              qrCodeScan(
                  context: context,
                  qrCode: qrCode.trim().replaceAll(RegExp(r'(\n){3,}'), "\n\n"),
                  clear: clear);
            } else {
              if (event.character != null) {
                qrCode = qrCode + event.character!;
              }
              if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
                qrCode = qrCode.substring(0, qrCode.length - 1);
              }
            }
            handleKey(event.data);
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Lottie.asset(
                    !widget.ticketDetail.isScanned
                        ? 'assets/lottie/successful.json'
                        : 'assets/lottie/error.json',
                    fit: BoxFit.fitWidth,
                    repeat: false,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                Text(qrCode),
                loading
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          height: 35,
                          width: 35,
                          child: CircularProgressIndicator(),
                        ),
                    )
                    : Container(),
                Text(
                  !widget.ticketDetail.isScanned ? "Ticket Scanned" : "Ticket already Scanned",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: !widget.ticketDetail.isScanned
                        ? Theme.of(context).primaryColor
                        : Colors.red,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(widget.ticketDetail.offlineTicket.number),
                const SizedBox(
                  height: 32,
                ),
                widget.ticketDetail.isScanned ? Text("Last Scanned") : Container(),
                const SizedBox(
                  height: 8,
                ),
                widget.ticketDetail.isScanned
                    ? Text(
                        DateFormat()
                            .add_yMd()
                            .format(getCurrentDateTime(widget.ticketDetail.modifiedTs)),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    : Container(),
                const SizedBox(
                  height: 8,
                ),
                widget.ticketDetail.isScanned
                    ? Text(
                        DateFormat()
                            .add_jms()
                            .format(getCurrentDateTime(widget.ticketDetail.modifiedTs)),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Container(),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: const BorderSide(color: Colors.green))),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScanScreen(),
                            ),
                          );
                        },
                        child: Row(
                          children: [Text("Continue"), Icon(Icons.keyboard_arrow_right)],
                        )),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  void qrCodeScan(
      {required BuildContext context, required String qrCode, required Function clear}) async {
    setState(() {
      loading = true;
    });
    ScannerRepository.scanTicket(context: context, ticketNumber: qrCode).then((value) {
      if (value != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PostTicketScanScreen(
              ticketDetail: value,
            ),
          ),
        ).then((value) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          clear();
          
        });
      } else {
        setState(() {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          clear();
        });
      }
    });
  }

  void handleKey(RawKeyEventData data) {
    setState(() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }
}

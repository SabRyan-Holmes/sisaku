import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sisaku/pages/category_page.dart';
import 'package:sisaku/pages/home_page.dart';
import 'package:sisaku/pages/rekap_page.dart';
import 'package:sisaku/pages/setting_page.dart';
import 'package:sisaku/widgets/image_input.dart';
import 'package:sisaku/colors.dart';
import 'dart:io';
import 'package:sisaku/models/database.dart';
import 'package:sisaku/models/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;

  const TransactionPage({
    super.key,
    required this.transactionWithCategory,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late int type;
  final AppDb database = AppDb();

  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  Category? selectedCategory;
  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  String dbDate = '';
  Uint8List? imageLama;

  @override
  void initState() {
    if (widget.transactionWithCategory != null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      updateType(1);
      type = type;
    }
    super.initState();
  }

  void updateType(int index) {
    setState(() {
      type = index;
      selectedCategory = null;
    });
    print("tipe sekarang : " + type.toString());
  }

  void updateTransactionView(TransactionWithCategory transactionWithCategory) {
    amountController.text =
        transactionWithCategory.transaction.amount.toString();
    deskripsiController.text = transactionWithCategory.transaction.name;
    dateController.text = DateFormat('dd-MMMM-yyyy')
        .format(transactionWithCategory.transaction.transaction_date);
    dbDate = DateFormat('yyyy-MM-dd')
        .format(transactionWithCategory.transaction.transaction_date);
    type = transactionWithCategory.category.type;
    selectedCategory = transactionWithCategory.category;
    imageLama = transactionWithCategory.transaction.image;
  }

  Future insert(int amount, DateTime date, String deskripsi, int categoryId,
      Uint8List? imageDb) async {
    return await database.insertTransaction(
        amount, date, deskripsi, categoryId, imageDb);
  }

  Future update(int transactionId, int amount, int categoryId,
      DateTime transactionDate, String deskripsi, Uint8List? imageDb) async {
    return await database.updateTransactionRepo(
      transactionId,
      amount,
      categoryId,
      transactionDate,
      deskripsi,
      imageDb,
    );
  }

  convertImageToUint8List(File image) {
    // Baca data gambar sebagai byte
    List<int> bytes = image.readAsBytesSync();

    // Konversi ke Uint8List
    Uint8List uint8List = Uint8List.fromList(bytes);

    return uint8List;
  }

  // Parameter untuk ImageInput
  File? savedImage;
  Uint8List? imageDb;
  void savedImages(File image) {
    savedImage = image;
    imageDb = convertImageToUint8List(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
        child: Container(
          color: primary,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tambah Transaksi",
                  style: GoogleFonts.montserrat(
                    fontSize: 23,
                    color: base,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (type == 1) ? primary : base,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      topLeft: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.download_outlined,
                                        color: (type == 1)
                                            ? base
                                            : Colors.green[300],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          updateType(1);
                                        },
                                        child: Text(
                                          "Pemasukan",
                                          style: GoogleFonts.montserrat(
                                            color: (type == 1) ? base : primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (type == 2) ? primary : base,
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          updateType(2);
                                        },
                                        child: Text(
                                          "Pengeluaran",
                                          style: GoogleFonts.montserrat(
                                            color: (type == 2) ? base : primary,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.upload_outlined,
                                        color: (type == 2)
                                            ? base
                                            : Colors.red[300],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: TextFormField(
                              controller: deskripsiController,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Deskripsi',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Jumlah Uang',
                              ),
                            ),
                          ),

                          // SizedBox(
                          //   height: 10,
                          // ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextFormField(
                              readOnly: true,
                              controller: dateController,
                              decoration: InputDecoration(
                                labelText: 'Pilih Tanggal',
                                suffixIcon: Icon(
                                  Icons.calendar_month_rounded,
                                  color: primary,
                                ),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialEntryMode:
                                      DatePickerEntryMode.calendarOnly,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2099),
                                );

                                if (pickedDate != Null) {
                                  String formattedDate =
                                      DateFormat('dd-MMMM-yyyy')
                                          .format(pickedDate!);
                                  dateController.text = formattedDate;
                                  String data = DateFormat('yyyy-MM-dd')
                                      .format(pickedDate);
                                  setState(() {
                                    dbDate = data;
                                  });
                                }
                              },
                            ),
                          ),

                          FutureBuilder<List<Category>>(
                            future: getAllCategory(type),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.length > 0) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: DropdownButtonFormField<Category>(
                                        decoration: InputDecoration(
                                          hintText: 'Pilih Kategori',
                                        ),
                                        isExpanded: true,
                                        value: selectedCategory,
                                        icon: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 11),
                                          child: Icon(
                                            Icons.arrow_drop_down,
                                            color: primary,
                                          ),
                                        ),
                                        items:
                                            snapshot.data!.map((Category item) {
                                          return DropdownMenuItem<Category>(
                                            value: item,
                                            child: Text(item.name),
                                          );
                                        }).toList(),
                                        onChanged: (Category? value) {
                                          setState(() {
                                            selectedCategory = value;
                                          });
                                        },
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 24.0, horizontal: 18.0),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Kategori tidak ada'),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  // DetailPage adalah halaman yang dituju
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CategoryPage(),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.add,
                                                color: base,
                                              ),
                                              label: Text(
                                                'Tambah kategori',
                                                style: GoogleFonts.montserrat(
                                                    color: base),
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  primary,
                                                ),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24.0),
                                    child: Center(
                                      child: Text('Kategori tidak ada'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),

                          SizedBox(
                            height: 25,
                          ),
                          (imageLama != null)
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Gambar Lama",
                                              style: GoogleFonts.montserrat(),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 2, color: primary),
                                              ),
                                              child: Image.memory(
                                                imageLama!,
                                                width: 200,
                                                height: 200,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Gambar Baru(opsional)",
                                              style: GoogleFonts.montserrat(),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            ImageInput(
                                              imagesaveat: savedImages,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Gambar (opsional)",
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ImageInput(imagesaveat: savedImages),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 25,
                          ),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 20, 16, 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        (widget.transactionWithCategory == null)
                                            ? await insert(
                                                int.parse(
                                                    amountController.text),
                                                DateTime.parse(dbDate),
                                                deskripsiController.text,
                                                selectedCategory!.id,
                                                imageDb,
                                              )
                                            : await update(
                                                widget.transactionWithCategory!
                                                    .transaction.id,
                                                int.parse(
                                                    amountController.text),
                                                selectedCategory!.id,
                                                DateTime.parse(dbDate),
                                                deskripsiController.text,
                                                imageDb,
                                              );

                                        // Navigator.pop(context);
                                        await Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomePage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Simpan Transaksi',
                                        style: GoogleFonts.montserrat(
                                          color: base,
                                          fontSize: 15,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            // (isExpense) ? MaterialStateProperty.all<Color>(Colors.red) :
                                            MaterialStateProperty.all<Color>(
                                                primary),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: primary,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.home,
                  color: Colors.black,
                ),
              ),
            ),
            // SizedBox(
            //   width: 20,
            // ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.list,
                  color: Colors.black,
                ),
              ),
            ),

            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => RekapPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.bar_chart,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SettingPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
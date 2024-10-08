class Customer {
  final String nama;
  final String noPelanggan;
  final String alamat;

  Customer({
    required this.nama,
    required this.noPelanggan,
    required this.alamat,
  });
}

List<Customer> generateDummyCustomers() {
  return [
    Customer(
      nama: 'John Doe',
      noPelanggan: 'PLG001',
      alamat: '123 Main Street, City A',
    ),
    Customer(
      nama: 'Jane Smith',
      noPelanggan: 'PLG002',
      alamat: '456 Elm Street, City B',
    ),
    Customer(
      nama: 'Alice Johnson',
      noPelanggan: 'PLG003',
      alamat: '789 Oak Street, City C',
    ),
    Customer(
      nama: 'Bob Brown',
      noPelanggan: 'PLG004',
      alamat: '321 Pine Street, City D',
    ),
    Customer(
      nama: 'Emily Wilson',
      noPelanggan: 'PLG005',
      alamat: '654 Maple Street, City E',
    ),
    Customer(
      nama: 'Michael Lee',
      noPelanggan: 'PLG006',
      alamat: '987 Birch Street, City F',
    ),
    Customer(
      nama: 'Sophia Garcia',
      noPelanggan: 'PLG007',
      alamat: '741 Cedar Street, City G',
    ),
    Customer(
      nama: 'Daniel Martinez',
      noPelanggan: 'PLG008',
      alamat: '852 Walnut Street, City H',
    ),
    Customer(
      nama: 'Olivia Perez',
      noPelanggan: 'PLG009',
      alamat: '369 Spruce Street, City I',
    ),
    Customer(
      nama: 'Liam Taylor',
      noPelanggan: 'PLG010',
      alamat: '159 Fir Street, City J',
    ),
  ];
}

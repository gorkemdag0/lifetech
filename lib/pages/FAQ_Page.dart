import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sıkça Sorulan Sorular'),
      ),
      body: ListView(
        children: const [
          FAQItem(
            question: 'Uygulamanın amacı nedir?',
            answer:
            'Uygulamamızın amacı, kullanıcıların her durumda kendilerini güvende hissetmelerini sağlamak ve gelişebilecek herhangi bir olumsuzlukta yetkililerin intikalini hızlandırmayı amaçlamaktadır.',
          ),
          FAQItem(
            question: 'Uygulama nasıl çalışır?',
            answer:
            'Uygulamamız, kişinin cihazından konum erişim izni aldıktan ve buton aktive edildikten sonra olağandışı sarsılmaları ve titreşimleri algılar. Eğer geri dönüş alamaz ise yetkililerle kişinin en sonki konum ve kayıt esnasında alınan bilgilerini paylaşır. Böylelikle yetkililerin en hızlı şekilde olay yerine intikali sağlanır.',
          ),
          FAQItem(
            question: 'Uygulamayı kullanmak ücretli mi?',
            answer:
            'Uygulamamız tamamen sosyal sorumluluk ve Avrupa Birliği sürdürülebilirlik maddelerine dayanarak hazırlanmıştır. Uygulama kapsamında hiçbir ücret talep edilmemektedir.',
          ),
          FAQItem(
            question: 'Bilgilerimi güncellemek istiyorum. Ne yapmalıyım?',
            answer:
            'Bilgilerinizi uygulama ekranında sağ üstteki profil bölümünden güncelleyebilirsiniz.',
          ),
          FAQItem(
            question: 'Yanlış ihbarların bir yaptırımı var mı?',
            answer:
            'Uygulamanın suistimal edilmesi durumunda bulunduğunuz ülkenin anayasasına göre yasal süreç başlatılır.',
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({super.key, required this.question, required this.answer});

  @override
  _FAQItemState createState() {
    return _FAQItemState();
  }
}

class _FAQItemState extends State<FAQItem> {
  final bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Card(
      child: ExpansionTile(
        title: Text(widget.question),
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Text(widget.answer),
          ),
        ],
      ),
    );
  }
}

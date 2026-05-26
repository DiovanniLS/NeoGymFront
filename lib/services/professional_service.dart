import '../models/professional.dart';

class ProfessionalService {

  Future<List<Professional>>
  getProfessionals() async {

    await Future.delayed(
      const Duration(seconds: 1),
    );

    return [

      Professional.fromMap({

        "id": "1",

        "name": "João Silva",

        "specialty":
        "Personal Trainer",

        "rating": 4.8,

        "distance": 2.3,

        "image":
        "https://i.pravatar.cc/150?img=3",

        "online": true,

        "type": "Personal",

        "workplaces": [
          {
            "id": "1",
            "name":
            "Smart Fit Paulista",
            "type": "Academia",
            "lat": -23.5,
            "lng": -46.6,
            "address":
            "Av. Paulista"
          }
        ]
      }),
    ];
  }
}
enum DeliveryType {
  doorstep('Doorstep Delivery', 'KES 250', 'Delivery to your home address'),
  schoolGate('Direct to School Gate', 'FREE with Chama / KES 100', 'Deliver to school gate'),
  courier('G4S/Fargo Courier Pickup', 'KES 180', 'Pickup at courier branch'),
  ;

  final String label;
  final String priceLabel;
  final String description;

  const DeliveryType(this.label, this.priceLabel, this.description);
}

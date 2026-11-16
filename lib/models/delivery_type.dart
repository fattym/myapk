enum DeliveryType {
  doorstep('Home Delivery (within Nairobi)', 'KES 300', 'Delivery to your home address'),
  schoolGate('Direct to School Gate', '', 'Deliver to school gate'),
  courier('G4S/Fargo Courier Pickup', '', 'Pickup at courier branch'),
  ;

  final String label;
  final String priceLabel;
  final String description;

  const DeliveryType(this.label, this.priceLabel, this.description);
}

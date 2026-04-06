/// Replaces placeholders in admin-defined China warehouse templates.
String applyChinaAddressId(String template, String customerId) {
  return template
      .replaceAll('(ID)', customerId)
      .replaceAll('{ID}', customerId);
}

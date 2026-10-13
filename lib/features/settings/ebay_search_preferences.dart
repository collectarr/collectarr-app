enum EbaySearchFilter {
  automatic('Automatic'),
  all('Show all eBay listings'),
  sold('Show Sold listings only');

  const EbaySearchFilter(this.label);
  final String label;

  bool soldOnlyFor({required bool isWishlisted}) => switch (this) {
        automatic => !isWishlisted,
        all => false,
        sold => true,
      };
}

enum EbayRegion {
  defaultRegion('Default region', 'www.ebay.com'),
  at('eBay AT', 'www.ebay.at'),
  au('eBay AU', 'www.ebay.com.au'),
  beNl('eBay BE (NL)', 'www.benl.ebay.be'),
  beFr('eBay BE (FR)', 'www.befr.ebay.be'),
  ca('eBay CA', 'www.ebay.ca'),
  ch('eBay CH', 'www.ebay.ch'),
  de('eBay DE', 'www.ebay.de'),
  es('eBay ES', 'www.ebay.es'),
  fr('eBay FR', 'www.ebay.fr'),
  ie('eBay IE', 'www.ebay.ie'),
  gb('eBay GB', 'www.ebay.co.uk'),
  it('eBay IT', 'www.ebay.it'),
  nl('eBay NL', 'www.ebay.nl'),
  pl('eBay PL', 'www.ebay.pl'),
  us('eBay US', 'www.ebay.com');

  const EbayRegion(this.label, this.host);
  final String label;
  final String host;
}

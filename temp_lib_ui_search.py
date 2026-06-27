import pathlib, re
path = pathlib.Path('lib')
phrases = [
    'Payment Success!', 'Your item will be shipped soon!', 'Select Payment Method', 'Google pay', 'Master Card', 'Credit Card',
    'On Snap!', 'Oh Snap', 'OH Snap', 'Email Sent', 'Email Link to Reset Your Password', 'Add new address', 'Phone Number', 'Postal Code',
    'First name', 'Last name', 'Re-Authenticate User', 'Accept Privacy policy', 'Your account has been created! verify email to continue.',
    'Pleas Check your inbox and verify your email.', 'Storing Address...', 'Your address has been saved successfully.', 'Address not found',
    'Your Name has been updated.', 'Data not saved', 'something went wrong while saving your information. you can re-save your data in your profile.',
    'Delete Account', 'Shipping Address', 'Select Address', 'Select Qauntity', 'Select Variation',
    'Selected variation is out of stock.', 'Selected product is out of stock.', 'Your product has been added to the Cart.', 'Remove Product',
    'Product removed from the Cart.', 'Product has been added to the wishlist.', 'Product has been removed to the wishlist.',
    'Error initializing image cache:', 'Error preloading images:', 'Error preloading single image:', 'Error clearing image cache:',
    'Error updating cache stats:', 'No Data Found!', 'Something went wrong.', 'No Internet Connection'
]
regex = re.compile('|'.join(re.escape(p) for p in phrases))
for p in path.rglob('*.dart'):
    text = p.read_text(encoding='utf-8', errors='ignore')
    for i, line in enumerate(text.splitlines(), 1):
        if regex.search(line):
            print(f'{p}:{i}:{line.strip()}')

import os
folders = ['static/qr_codes', 'static/certificates', 'static/images/players', 'static/reports']
for f in folders:
    os.makedirs(f, exist_ok=True)
    test_file = os.path.join(f, '.write_test')
    try:
        open(test_file, 'w').close()
        os.remove(test_file)
        print('OK ' + f + ' - writable')
    except:
        print('ERROR ' + f + ' - PERMISSION ERROR')
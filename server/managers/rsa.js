const NodeRSA = require('node-rsa');

exports("GenerateKeys", (cb) => {
    if (GetInvokingResource()) {
        const key = new NodeRSA({b: 1024});

        cb(key.exportKey("public"), key.exportKey("private"))
    }
})

exports("Decrypt", (privatekey, encrypted, cb) => {
    if (GetInvokingResource()) {
        // Key importation
        const key = new NodeRSA();
        key.importKey(privatekey, "pkcs1-private")

        // Decryption
        const decrypted = key.decrypt(encrypted, "utf8")

        // Return
        cb(decrypted)
    }
})

exports("Encrypt", (publickey, text, cb) => {
    if (GetInvokingResource()) {
        // Key importation
        const key = new NodeRSA();
        key.importKey(publickey, "pkcs8-public")

        // Encryption
        const encrypted = key.encrypt(text, "base64")

        // Return
        cb(encrypted)
    }
})


const NodeRSA = require('node-rsa');

function Post(event, obj) {
    fetch(`https://${GetParentResourceName()}/`+event, {
        method: "POST",
        body: JSON.stringify(obj)
    })
}

window.addEventListener("message", (event) => {
    if (event.data.type == "generate") {
        const key = new NodeRSA({b: 1024});
        Post("GenerateKey", {
          "publicKey": key.exportKey('public'),
          "privateKey": key.exportKey('private')
        })
    } else if (event.data.type == "decrypt") {
        // Key importation
        const key = new NodeRSA();
        key.importKey(event.data.private, "pkcs1-private")

        // Decryption
        const decrypted = key.decrypt(event.data.encrypted, "utf8")

        // Return
        Post("Decrypted", {
            "decrypted": decrypted
        })
    } else if (event.data.type == "encrypt") {
        // Key importation
        const key = new NodeRSA();
        key.importKey(event.data.public, "pkcs8-public")

        // Encryption
        const encrypted = key.encrypt(event.data.text, "base64")

        // Return
        Post("Encrypted", {
            "encrypted": encrypted
        })
    }
});
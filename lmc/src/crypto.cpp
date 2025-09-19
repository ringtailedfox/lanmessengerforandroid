/****************************************************************************
**
** This file is part of LAN Messenger.
**
** Copyright (c) 2010 - 2012 Qualia Digital Solutions.
**
** Contact:  qualiatech@gmail.com
**
** LAN Messenger is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** LAN Messenger is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with LAN Messenger.  If not, see <http://www.gnu.org/licenses/>.
**
****************************************************************************/


#include "trace.h"
#include "crypto.h"

lmcCrypto::lmcCrypto(void) {
    pKey = nullptr;
    encryptMap.clear();
    decryptMap.clear();
    bits = 1024;
    exponent = 65537;
}

lmcCrypto::~lmcCrypto(void) {
    EVP_PKEY_free(pKey);
}

//	creates an RSA key pair and returns the string representation of the public key
QByteArray lmcCrypto::generateRSA(void) {
    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_RSA, NULL);
    EVP_PKEY_keygen_init(ctx);
    EVP_PKEY_CTX_set_rsa_keygen_bits(ctx, bits);
    EVP_PKEY_keygen(ctx, &pKey);
    EVP_PKEY_CTX_free(ctx);

    BIO* bio = BIO_new(BIO_s_mem());
    PEM_write_bio_PUBKEY(bio, pKey);  // Modern format
    int keylen = BIO_pending(bio);
    char* pem_key = (char*)calloc(keylen + 1, 1);
    BIO_read(bio, pem_key, keylen);
    publicKey = QByteArray(pem_key, keylen);
    BIO_free_all(bio);
    free(pem_key);

    return publicKey;
}

//	generates a random aes key and iv, and encrypts it with the public key
QByteArray lmcCrypto::generateAES(QString* lpszUserId, QByteArray& pubKey) {
EVP_PKEY* pubKeyObj = nullptr;
BIO* bio = BIO_new_mem_buf(pubKey.data(), pubKey.length());
PEM_read_bio_PUBKEY(bio, &pubKeyObj, NULL, NULL);
BIO_free(bio);

int keyDataLen = 32;
unsigned char* keyData = (unsigned char*)malloc(keyDataLen);
RAND_bytes(keyData, keyDataLen);
int keyLen = 32;
int ivLen = EVP_CIPHER_iv_length(EVP_aes_256_cbc());
int keyIvLen = keyLen + ivLen;
unsigned char* keyIv = (unsigned char*)malloc(keyIvLen);
int rounds = 5;
keyLen = EVP_BytesToKey(EVP_aes_256_cbc(), EVP_sha1(), NULL, keyData, keyDataLen, rounds, keyIv, keyIv + keyLen);

EVP_CIPHER_CTX ectx, dctx;
EVP_EncryptInit_ex(ectx.ptr(), EVP_aes_256_cbc(), NULL, keyIv, keyIv + keyLen);
encryptMap.insert(*lpszUserId, ectx);
EVP_CIPHER_CTX_init(dctx.ptr());
EVP_DecryptInit_ex(dctx.ptr(), EVP_aes_256_cbc(), NULL, keyIv, keyIv + keyLen);
decryptMap.insert(*lpszUserId, dctx);

EVP_PKEY_CTX* encCtx = EVP_PKEY_CTX_new(pubKeyObj, NULL);
EVP_PKEY_encrypt_init(encCtx);
EVP_PKEY_CTX_set_rsa_padding(encCtx, RSA_PKCS1_OAEP_PADDING);
size_t outlen = 0;
EVP_PKEY_encrypt(encCtx, NULL, &outlen, keyIv, keyIvLen);
unsigned char* eKeyIv = (unsigned char*)malloc(outlen);
EVP_PKEY_encrypt(encCtx, eKeyIv, &outlen, keyIv, keyIvLen);
EVP_PKEY_CTX_free(encCtx);

QByteArray baKeyIv((char*)eKeyIv, outlen);

EVP_PKEY_free(pubKeyObj);
free(keyIv);
free(eKeyIv);
free(keyData);

return baKeyIv;
}

//	decrypts the aes key and iv with the private key
void lmcCrypto::retreiveAES(QString* lpszUserId, QByteArray& aesKeyIv) {
    EVP_PKEY_CTX* decCtx = EVP_PKEY_CTX_new(pKey, NULL);
    EVP_PKEY_decrypt_init(decCtx);
    EVP_PKEY_CTX_set_rsa_padding(decCtx, RSA_PKCS1_OAEP_PADDING);
    size_t outlen = 0;
    EVP_PKEY_decrypt(decCtx, NULL, &outlen, (unsigned char*)aesKeyIv.data(), aesKeyIv.length());
    unsigned char* keyIv = (unsigned char*)malloc(outlen);
    EVP_PKEY_decrypt(decCtx, keyIv, &outlen, (unsigned char*)aesKeyIv.data(), aesKeyIv.length());
    EVP_PKEY_CTX_free(decCtx);

	int keyLen = 32;
	EVP_CIPHER_CTX ectx, dctx;
	EVP_EncryptInit_ex(ectx.ptr(), EVP_aes_256_cbc(), NULL, keyIv, keyIv + keyLen);
	encryptMap.insert(*lpszUserId, ectx);
	EVP_DecryptInit_ex(dctx.ptr(), EVP_aes_256_cbc(), NULL, keyIv, keyIv + keyLen);
	decryptMap.insert(*lpszUserId, dctx);

	free(keyIv);
}

QByteArray lmcCrypto::encrypt(QString* lpszUserId, QByteArray& clearData) {
	int outLen = clearData.length() + AES_BLOCK_SIZE;
	unsigned char* outBuffer = (unsigned char*)malloc(outLen);
	if(outBuffer == NULL) {
		lmcTrace::write("Error: Buffer not allocated");
		return QByteArray();
	}
	int foutLen = 0;

	EVP_CIPHER_CTX ctx = encryptMap.value(*lpszUserId);
	if(EVP_EncryptInit_ex(ctx.ptr(), NULL, NULL, NULL, NULL)) {
		if(EVP_EncryptUpdate(ctx.ptr(), outBuffer, &outLen, (unsigned char*)clearData.data(), clearData.length())) {
			if(EVP_EncryptFinal_ex(ctx.ptr(), outBuffer + outLen, &foutLen)) {
				outLen += foutLen;
				QByteArray byteArray((char*)outBuffer, outLen);
				free(outBuffer);
				return byteArray;
			}
		}
	}
	lmcTrace::write("Error: Message encryption failed");
	return QByteArray();
}

QByteArray lmcCrypto::decrypt(QString* lpszUserId, QByteArray& cipherData) {
	int outLen = cipherData.length();
	unsigned char* outBuffer = (unsigned char*)malloc(outLen);
	if(outBuffer == NULL) {
		lmcTrace::write("Error: Buffer not allocated");
		return QByteArray();
	}
	int foutLen = 0;

	EVP_CIPHER_CTX ctx = decryptMap.value(*lpszUserId);
	if(EVP_DecryptInit_ex(ctx.ptr(), NULL, NULL, NULL, NULL)) {
		if(EVP_DecryptUpdate(ctx.ptr(), outBuffer, &outLen, (unsigned char*)cipherData.data(), cipherData.length())) {
			if(EVP_DecryptFinal_ex(ctx.ptr(), outBuffer + outLen, &foutLen)) {
				outLen += foutLen;
				QByteArray byteArray((char*)outBuffer, outLen);
				free(outBuffer);
				return byteArray;
			}
		}
	}
	lmcTrace::write("Error: Message decryption failed");
	return QByteArray();
}

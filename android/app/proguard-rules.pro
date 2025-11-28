# Keep JSch classes
-keep class com.jcraft.jsch.** { *; }

# Keep Zebra RFID SDK classes
-keep class com.zebra.rfid.api3.** { *; }

# Keep BouncyCastle crypto classes
-keep class org.bouncycastle.** { *; }

# Keep Apache Xerces classes
-keep class org.apache.xerces.** { *; }
# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.jcraft.jsch.Channel
-dontwarn com.jcraft.jsch.ChannelSftp
-dontwarn com.jcraft.jsch.JSch
-dontwarn com.jcraft.jsch.JSchException
-dontwarn com.jcraft.jsch.Session
-dontwarn com.jcraft.jsch.SftpException
-dontwarn org.apache.xerces.dom.DOMInputImpl
-dontwarn org.apache.xerces.jaxp.DocumentBuilderFactoryImpl
-dontwarn org.bouncycastle.crypto.BlockCipher
-dontwarn org.bouncycastle.crypto.CipherParameters
-dontwarn org.bouncycastle.crypto.InvalidCipherTextException
-dontwarn org.bouncycastle.crypto.engines.AESEngine
-dontwarn org.bouncycastle.crypto.engines.RFC5649WrapEngine
-dontwarn org.bouncycastle.crypto.params.KeyParameter
-dontwarn org.bouncycastle.util.encoders.Hex
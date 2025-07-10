using System.IO;
using System.Linq;

namespace server.Application.Services;

public static class AudioSignatureDetector
{
    public static bool ValidateAudioExtension(this Stream audioStream)
    {
        audioStream.Position = 0;
        var buffer = new byte[32]; 
        var bytesRead = audioStream.Read(buffer, 0, 32);
        audioStream.Position = 0;

        return bytesRead >= 4 && 
               (IsMp3(buffer) || IsWav(buffer) || IsOgg(buffer) || 
                IsFlac(buffer) || IsWebM(buffer, bytesRead) || IsMp4Audio(buffer));
    }

    private static bool IsMp3(byte[] buffer)
    {
        if (buffer is [0x49, 0x44, 0x33, ..])
            return true;

        return buffer is [0xFF, _, ..] && (buffer[1] & 0xE0) == 0xE0;
    }

    private static bool IsWav(byte[] buffer)
    {
        return buffer.Length >= 12 &&
               buffer[0] == 0x52 && buffer[1] == 0x49 && buffer[2] == 0x46 && buffer[3] == 0x46 && // "RIFF"
               buffer[8] == 0x57 && buffer[9] == 0x41 && buffer[10] == 0x56 && buffer[11] == 0x45;   // "WAVE"
    }

    private static bool IsOgg(byte[] buffer)
    {
        return buffer is [0x4F, 0x67, 0x67, 0x53, ..]; // "OggS"
    }

    private static bool IsFlac(byte[] buffer)
    {
        return buffer is [0x66, 0x4C, 0x61, 0x43, ..]; // "fLaC"
    }

    private static bool IsWebM(byte[] buffer, int bytesRead)
    {
        if (bytesRead >= 4 && buffer[0] == 0x1A && buffer[1] == 0x45 && buffer[2] == 0xDF && buffer[3] == 0xA3)
        {
            for (var i = 4; i < bytesRead - 3; i++)
            {
                if (buffer[i] == 0x77 && buffer[i + 1] == 0x65 && 
                    buffer[i + 2] == 0x62 && buffer[i + 3] == 0x6D) // "webm"
                {
                    return true;
                }
            }
        }
        return false;
    }

    private static bool IsMp4Audio(byte[] buffer)
    {
        if (buffer.Length >= 8 &&
            buffer[4] == 0x66 && buffer[5] == 0x74 && buffer[6] == 0x79 && buffer[7] == 0x70) // "ftyp"
        {
            if (buffer.Length >= 12)
            {
                var brandCode = new string(new char[] { 
                    (char)buffer[8], (char)buffer[9], (char)buffer[10], (char)buffer[11] 
                });
                var audioBrands = new[] { "M4A ", "mp42", "isom", "aac " };
                return audioBrands.Contains(brandCode);
            }
        }
        return false;
    }
}
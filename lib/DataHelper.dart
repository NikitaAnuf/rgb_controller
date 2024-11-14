int packBits(List<int> byteArray, int bitPosition, int value, int bitLength) {
  for (int i = 0; i < bitLength; i++) {
    int byteIndex = bitPosition ~/ 8;
    int bitOffset = 7 - (bitPosition % 8);

    if (bitPosition % 8 == 0) {
      // Инициализируем байт, если это начало нового байта
      byteArray[byteIndex] = 0;
    }

    // Устанавливаем нужный бит
    byteArray[byteIndex] |= ((value >> (bitLength - 1 - i)) & 1) << bitOffset;
    bitPosition++;
  }

  return bitPosition;
}

int appendByteArray(int effectIndex, List<int> values, List<int> byteArray, int bitPosition) {
  bitPosition = packBits(byteArray, bitPosition, effectIndex, 32);

  for (var value in values) {
    bitPosition = packBits(byteArray, bitPosition, value, 32);
  }

  return bitPosition;
}

// void sendBytes(List<int> byteArray, int size)
// {
//   Get.put(BlueToothController()).targetCharacteristic.value!.write(byteArray.sublist(0, size));
// }
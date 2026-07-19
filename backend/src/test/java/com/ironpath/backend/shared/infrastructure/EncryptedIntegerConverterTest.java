package com.ironpath.backend.shared.infrastructure;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class EncryptedIntegerConverterTest {

    @Mock
    private AesGcmCipherService cipherService;

    @InjectMocks
    private EncryptedIntegerConverter converter;

    @Test
    void convertToDatabaseColumn_shouldEncryptStringRepresentation_whenAttributeNotNull() {
        when(cipherService.encrypt("1800")).thenReturn("encrypted-value");

        String result = converter.convertToDatabaseColumn(1800);

        assertEquals("encrypted-value", result);
    }

    @Test
    void convertToDatabaseColumn_shouldReturnNull_whenAttributeIsNull() {
        String result = converter.convertToDatabaseColumn(null);

        assertNull(result);
        verifyNoInteractions(cipherService);
    }

    @Test
    void convertToEntityAttribute_shouldDecryptAndParseInteger_whenDbDataNotNull() {
        when(cipherService.decrypt("encrypted-value")).thenReturn("1800");

        Integer result = converter.convertToEntityAttribute("encrypted-value");

        assertEquals(1800, result);
    }

    @Test
    void convertToEntityAttribute_shouldReturnNull_whenDbDataIsNull() {
        Integer result = converter.convertToEntityAttribute(null);

        assertNull(result);
        verifyNoInteractions(cipherService);
    }
}

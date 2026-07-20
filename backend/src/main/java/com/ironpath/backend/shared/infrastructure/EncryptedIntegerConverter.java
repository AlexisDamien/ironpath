package com.ironpath.backend.shared.infrastructure;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@Converter
@RequiredArgsConstructor
public class EncryptedIntegerConverter implements AttributeConverter<Integer, String> {

    private final AesGcmCipherService cipherService;

    @Override
    public String convertToDatabaseColumn(Integer attribute) {
        return attribute == null ? null : cipherService.encrypt(attribute.toString());
    }

    @Override
    public Integer convertToEntityAttribute(String dbData) {
        return dbData == null ? null : Integer.parseInt(cipherService.decrypt(dbData));
    }
}
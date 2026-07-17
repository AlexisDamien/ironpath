package com.ironpath.backend.shared.infrastructure;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@Converter
@RequiredArgsConstructor
public class EncryptedDoubleConverter implements AttributeConverter<Double, String> {

    private final AesGcmCipherService cipherService;

    @Override
    public String convertToDatabaseColumn(Double attribute) {
        return attribute == null ? null : cipherService.encrypt(attribute.toString());
    }

    @Override
    public Double convertToEntityAttribute(String dbData) {
        return dbData == null ? null : Double.parseDouble(cipherService.decrypt(dbData));
    }
}
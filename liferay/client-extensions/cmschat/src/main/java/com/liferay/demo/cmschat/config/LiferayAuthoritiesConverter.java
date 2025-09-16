/**
 * Copyright (c) 2000-2025 Liferay, Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.liferay.demo.cmschat.config;

import org.springframework.core.convert.converter.Converter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

/*
 * This class reads the claims from the Liferay JWT Access Token
 * It extracts the scopes
 *
 * @author Neil Griffin
 */
public class LiferayAuthoritiesConverter implements Converter<Jwt, Collection<GrantedAuthority>> {

    @Override
    public Collection<GrantedAuthority> convert(final Jwt jwt) {

        List<GrantedAuthority> scopesCollection =
        		new ArrayList<>(
        				Arrays.asList(
        						((String) jwt.getClaim("scope")).split(" ")
        						)
        				).stream()
                .map(scopeName -> "SCOPE_" + scopeName)
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());

        List<GrantedAuthority> grantedAuthorities = scopesCollection;

		for (GrantedAuthority grantedAuthority : grantedAuthorities) {
			System.err.println("!@#$ grantedAuthority=" + grantedAuthority.getAuthority());
		}
        return grantedAuthorities;
    }
    
}

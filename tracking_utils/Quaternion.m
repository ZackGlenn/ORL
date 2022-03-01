classdef Quaternion
    properties
        w
        x
        y
        z
    end

    methods
        function q = Quaternion(w, x, y, z)
            q.w = w;
            q.x = x;
            q.y = y;
            q.z = z;
        end

        function q = from_parts(re, im)
            q.w = re;
            q.x = im(1);
            q.y = im(2);
            q.z = im(3);
        end

        function q = plus(a, b)
            q.w = a.w + b.w;
            q.x = a.x + b.x;
            q.y = a.y + b.y;
            q.z = a.z + b.z;
        end

        function q = minus(a, b)
            q.w = a.w - b.w;
            q.x = a.x - b.x;
            q.y = a.y - b.y;
            q.z = a.z - b.z;
        end

        function p = uminus(q)
            zero = Quaternion(0, 0, 0, 0);
            p = zero - q;
        end

        function p = uplus(a)
            p = a;
        end

        function q = times(a, b)
            if isdouble(a)
                q.w = a * b.w;
                q.x = a * b.x;
                q.y = a * b.y;
                q.z = a* b.z;
            elseif isdouble(b)
                q = b * a;
            else
                q.w = a.w .* b.w;
                q.x = a.x .* b.x;
                q.y = a.y .* b.y;
                q.z = a.z .* b.z;
            end
        end

        function q = mtimes(a, b)
            if isdouble(a) || isdouble(b)
                q = a.* b;
            else
                q.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z;
                q.x = a.w * b.x + a.w * b.x + a.y * b.z - a.z * b.y;
                q.y = a.w * b.x - a.x * b.y + a.y * b.w + a.z * b.x;
                q.z = a.w * b.x + a.x * b.w - a.y * b.x + a.z * b.w;
            end
        end

        function p = power(q, a)
            p.w = q.w^a;
            p.x = q.x^a;
            p.y = q.y^a;
            p.z = q.z^a;
        end

        function p = mpower(q, k)
            v = as_vec(q);
            A = norm(q);
            n = v ./ A;
            phi = acos(q.w / A);

            r = from_parts(cos(k * phi), n * sin(k * phi));
            p = A ^ k * r;
        end

        function a = subsref(q, s)
            switch s
                case 1
                    a = q.w;
                case 2
                    a = q.x;
                case 3
                    a = q.y;
                case 4
                    a = q.z;
                otherwise
                    error("Invalid index")
            end
        end

        function q = subasgn(q, s, a)
            switch s
                case 1
                    q.w = a;
                case 2
                    q.x = a;
                case 3
                    q.y = a;
                case 4
                    q.z = a;
                otherwise
                    error("Invalid index")
            end
        end

        function w = re(q)
            w = Quaternion(q.w, 0, 0, 0);
        end

        function v = im(q)
            v = Quaternion(0, q.x, q.y, q.z);
        end

        function p = conj(q)
            p.w = q.w;
            p.x = -q.x;
            p.y = -q.y;
            p.z = -q.z;
        end

        function v = as_vec(q)
            v = [q.w, q.x, q.y, q.z];
        end

        function a = norm(q)
            a = norm(as_vec(q));
        end

        function p = inv(q)
            n = norm(q);
            p = conj(q) / n / n;
        end

        function p = slerp(q1, q2, u)
            p = q1 * (inv(q1) * q2) ^ u;
        end

        function p = cubic_de_casteljau(q0, q1, q2, q3, t)
            p = [];
            for idx = 1:length(t)
                u = t(idx);
                slerp_01 = slerp(q0, q1, u);
                slerp_12 = slerp(q1, q2, u);
                slerp_23 = slerp(q2, q3, u);
                p(idx) = slerp(...
                    slerp(slerp_01, slerp_12, u), ...
                    slerp(slerp_12, slerp_23, u), ...
                    t ...
                );
            end
        end
    end
end